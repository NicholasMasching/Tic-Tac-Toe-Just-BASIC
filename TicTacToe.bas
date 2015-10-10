'This is an attempt at a minimax tic tac toe algorithm in Just BASIC
'the search tree will be contained in tree$
'the nodes will be strings delimited by commas, of the form
'   parentIndex,state
'states are 9 character strings of Xs, Os, and underscores
'   XXOOOXXOX as an example
'X
'XO
' OX

global gameState$, currentPlayer$, AIPlayer$, player1$

loadbmp "X", "x.bmp"
loadbmp "O", "o.bmp"
loadbmp "_", "blank.bmp"

 WindowWidth = 528
    WindowHeight = 430
    UpperLeftX = DisplayWidth/2 - 296
    UpperLeftY = DisplayHeight/2 - 215

    statictext #main.statictext1, "(Player Turn Display)", 38, 21, 136, 20
    statictext #main.statictext12, level$, 38, 41, 100, 20
    bmpbutton #main.box1, "blank.bmp", playerInput, UL, 25, 100
    bmpbutton #main.box2, "blank.bmp", playerInput, UL, 110, 100
    bmpbutton #main.box3, "blank.bmp", playerInput, UL, 195, 100
    bmpbutton #main.box4, "blank.bmp", playerInput, UL, 25, 185
    bmpbutton #main.box7, "blank.bmp", playerInput, UL, 25, 270
    bmpbutton #main.box5, "blank.bmp", playerInput, UL, 110, 185
    bmpbutton #main.box6, "blank.bmp", playerInput, UL, 195, 185
    bmpbutton #main.box8, "blank.bmp", playerInput, UL, 110, 270
    bmpbutton #main.box9, "blank.bmp", playerInput, UL, 195, 270
    graphicbox #main.graph1, 195, 10, 75, 75 'player turn display
        'statictext #main.statictext2, "Current series", 300, 100, 100, 20
        'statictext #main.statictext3, player1name$ + ": 0", 300, 120, 100, 20
        'statictext #main.statictext4, player2name$ + ": 0", 300, 140, 100, 20
        'graphicbox #main.graph2, 400, 100, 75, 75
        'statictext #main.statictext5, "Best " + str$(gamesToWin) + " out of " + str$(gamesToWin*2 -1), 300, 180, 100, 20
        'statictext #main.statictext9, "Current Leader:", 400, 80, 100, 20
        'statictext #main.statictext11, "Ties: 0", 300, 160, 100, 20
    'statictext #main.statictext6, "Series total:", 300, 240, 100, 20
    'statictext #main.statictext7, player1name$ + ": 0", 300, 260, 100, 20
    'statictext #main.statictext8, player2name$ + ": 0", 300, 280, 100, 20
    'graphicbox #main.graph3, 400, 240, 75, 75
    'statictext #main.statictext10, "Current Leader:", 400, 220, 100, 20
    button #main.default, "New Game", newGame, UL, 335, 320, 100, 40
    button #main.nothing, "", nothing, LL, 1, 1, 1, 1
    'button #main.newGame, "New Game", [newGame], UL, 420, 375, 100, 25

    statictext #main.gameMoves, "", 25, 375, 100, 20

    open "Tic Tac Toe" for window_nf as #main
    print #main, "trapclose closeMain"
    print #main.graph1, "fill white; flush"
    print #main.graph1, "when characterInput keyboard"
    print #main, "font ms_sans_serif 0 16"
    print #main.default, "!disable"

    player1$ = "X"
    call playGame player1$

    'wait

sub closeMain windowhandle$
    close #main
    stop
end sub

sub playerInput windowhandle$
    'notice windowhandle$ 
    print currentPlayer$
    print AIPlayer$
    move = val(right$(windowhandle$, 1))
    if mid$(gameState$, move, 1) = "_" then
        gameState$ = updateBoard$(gameState$, move)
        print "your turn"
        call printBoard gameState$
        if winner$(gameState$) = "" then
            call switchPlayer
            gameState$ = updateBoard$(gameState$, AIMove(gameState$, AIPlayer$))
            call printBoard gameState$
            call switchPlayer
        end if
        if not(winner$(gameState$) = "") then call gameOver
    end if
end sub

print "Game over"
stop

sub playGame player1$
    'test$ = "#main.box9"
    'print #test$, "bitmap ";"x"
    gameState$ = "_________"
    call printBoard gameState$
    currentPlayer$ = player1$
    AIPlayer$ = "O"
    while winner$(gameState$) = ""
        'gameState$ = updateBoard$(gameState$, takeTurn(gameState$))
        print #main.graph1, "drawbmp ";currentPlayer$;" 1 1"
        if currentPlayer$ = AIPlayer$ then 'if AI moves first
            gameState$ = updateBoard$(gameState$, AIMove(gameState$, AIPlayer$))
            call printBoard gameState$
            call switchPlayer
        end if
        wait
            'gameState$ = updateBoard$(gameState$, playerMove(gameState$))
        'end if
        call printBoard gameState$ 
        call switchPlayer
        print "-----------------"
    wend
    print "winner: " + winner$(gameState$)
end sub

function updateBoard$(board$, move)
    updateBoard$ = left$(board$, move - 1) + currentPlayer$ + mid$(board$, move + 1)
end function

sub gameOver
    print "winner: " + winner$(gameState$)
end sub

'returns the number of the space moved to
function takeTurn(board$)
    print #main.graph1, "drawbmp ";currentPlayer$;" 1 1"
    if currentPlayer$ = AIPlayer$ then
        takeTurn = AIMove(board$, AIPlayer$)
    else
        takeTurn = playerMove(board$)
    end if
end function

sub switchPlayer
    if currentPlayer$ = "X" then
        currentPlayer$ = "O"
    else
        currentPlayer$ = "X"
    end if
    print #main.graph1, "drawbmp ";currentPlayer$;" 1 1"
end sub

function AIMove(board$, AIPlayer$)
        AIMove = miniMaxMove(board$, AIPlayer$)
end function


function playerMove(board$)
    do
        input "Your move: "; playerMove
    loop while not(mid$(board$, playerMove, 1) = "_")
end function

sub printBoard state$
    for i = 0 to 2
        print mid$(state$, 3*i+1, 3)
    next i
    for i = 1 to 9
        handle$ = "#main.box" + str$(i)
        print #handle$, "bitmap ";mid$(state$, i, 1)
    next i
end sub


'returns comma seperated list of board after all possible moves by player
'first word is number of succesors
function successors$(board$, player$)
    successors$ = ""
    count = 0
    for i = 1 to 9
        if mid$(board$, i, 1) = "_" then
            successors$ = successors$ + ","  + left$(board$, i - 1) + player$ + mid$(board$, i + 1)
            count = count + 1
        end if
    next i
    successors$ = str$(count) + successors$
end function

function miniMaxMove(board$, player$)
    print ""
    maxVal = -1000
    successors$ = successors$(board$, player$)
    alpha = -10000
    beta = 10000
    for i = 1 to val(nthword$(successors$, 0, ","))
        print i
        tempBoard$ = nthword$(successors$, i, ",")
        score = minScore(tempBoard$, player$, alpha, beta)
        if score > maxVal then
            nextBoard$ = tempBoard$
            maxVal = score
        end if
    next i
    for i = 1 to 9
        if mid$(board$, i, 1) = "_" and mid$(nextBoard$, i, 1) = player$ then miniMaxMove = i
    next i
end function

'return value of sucessor node with highest utitlity value
function findMax(board$, player$, alpha, beta)
    successors$ = successors$(board$, player$)
    nsuccessors = val(nthword$(successors$, 0, ","))
    findMax = -1000
    for i = 1 to nsuccessors
        findMax = max(findMax, minScore(nthword$(successors$, i, ","), player$, alpha, beta))
        if findMax >= beta then exit function 'return findMax
        alpha = max(alpha, findMax)
        'if score > findMax then
        '    'findMax$ = nthword$(successors$, i, ",")
        '    findMax = score
        'end if
    next i
end function

'returns the score of a min node
function minScore(board$, maxPlayer$, alpha, beta)
    if winner$(board$) = maxPlayer$ then
        minScore = 1
    else
        if winner$(board$) = "tie" then
            minScore = 0
        else
            if winner$(board$) = "" then
                'return minimum of sucessors
                minScore = findMin(board$, maxPlayer$, alpha, beta)
            else
                minScore = -1
            end if
        end if
    end if
end function

function findMin(board$, player$, alpha, beta)
    if player$ = "X" then
        successors$ = successors$(board$, "O")
    else
        successors$ = successors$(board$, "X")
    end if
    nsuccessors = val(nthword$(successors$, 0, ","))
    findMin = 1000
    for i = 1 to nsuccessors
        findMin = min(findMin, maxScore(nthword$(successors$, i, ","), player$, alpha, beta)) 'maximize the min score
        if findMin <= alpha then exit function 'return findMin
        beta = min(beta, findMin)
        'if score < findMin then
        '    'findMin$ =  nthword$(successors$, i, ",")
        '    findMin = score
        'end if
    next i
end function

'returns the score of a max node
function maxScore(board$, maxPlayer$, alpha, beta)
    if winner$(board$) = maxPlayer$ then
        maxScore = 1
    else
        if winner$(board$) = "tie" then
            maxScore = 0
        else
            if winner$(board$) = "" then
                maxScore = findMax(board$, maxPlayer$, alpha, beta)
            else
                maxScore = -1
            end if
        end if
    end if
end function

function min(n1, n2)
    min = n1
    if n2 < n1 then min = n2
end function

function max(n1, n2)
    max = n1
    if n2 > n1 then max = n2
end function







'returns "X", "O", "tie", or ""
'"" means game not over
function winner$(state$)
    winner$ = "tie"
    if instr(state$, "_") then winner$ = ""
    if hasWon(state$, "X") then
        winner$ = "X"
        exit function
    end if
    if hasWon(state$, "O") then winner$ = "O"
end function

function hasWon(state$, player$)
    hasWon = isWinState(state$, player$, 1, 2, 3) or isWinState(state$, player$, 4, 5, 6) or isWinState(state$, player$, 7, 8, 9) or isWinState(state$, player$, 1, 4, 7) or isWinState(state$, player$, 2, 5, 8) or isWinState(state$, player$, 3, 6, 9) or isWinState(state$, player$, 1, 5, 9)  or isWinState(state$, player$, 3, 5, 7)
end function

'returns true if c1, c2, and c3 all contain player$
function isWinState(state$, player$, c1, c2, c3)
    isWinState = (mid$(state$, c1, 1) = player$ and mid$(state$, c2, 1) = player$ and mid$(state$, c3, 1) = player$)
end function

'returns the nth word in words, where delimiter$ is the character that separates words
'first word is 0th word
'returns "" if words$ has < n+1 words
function nthword$(words$, n, delimiter$)
    'trim front and back
    while right$(words$, 1) = delimiter$
        words$ = left$(words$, len(words$)-1)
    wend
    while left$(words$, 1) = delimiter$
        words$ = mid$(words$, 2)
    wend
   'extract word
    for i = 0 to n
        delimIndex = instr(words$, delimiter$)
        if delimIndex > 0 then
            word$ = left$(words$, instr(words$, delimiter$)-1)
            words$ = mid$(words$, delimIndex)
            while left$(words$, 1) = delimiter$ 'trim of any extra leading delimieters
                words$ = mid$(words$, 2)
            wend
        else    'there is one word left in words
            word$ = words$
            words$ = ""
        end if
    next i
    nthword$ = word$
end function



