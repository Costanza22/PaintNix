-- Definição das variáveis
local player = {} -- Jogador
local enemy = {} -- Inimigo
local items = {} -- Itens coletáveis

local gameover = false -- Flag de game over
local score = 0 -- Pontuação do jogador
local lives = 3 -- Vidas do jogador
local isPaused = false -- Flag de pausa do jogo
local congrats = false -- Flag de parabéns ao coletar todos os itens

-- Função de reiniciar o jogo
function restartGame()
    player.x = love.graphics.getWidth() / 2 - player.size / 2
    player.y = love.graphics.getHeight() / 2 - player.size / 2
    enemy.x = love.math.random(0, love.graphics.getWidth() - enemy.size)
    enemy.y = love.math.random(0, love.graphics.getHeight() - enemy.size)
    items = {}
    score = 0
    lives = 3
    gameover = false
    congrats = false
    
    -- Criação dos itens coletáveis
    local numItems = 20
    for i = 1, numItems do
        local item = {}
        item.size = 20
        item.x = love.math.random(0, love.graphics.getWidth() - item.size)
        item.y = love.math.random(0, love.graphics.getHeight() - item.size)
        item.collected = false -- Define o estado inicial como não coletado
        table.insert(items, item)
    end
end

-- Função de carregamento do jogo
function love.load()
    -- Configurações iniciais
    love.window.setTitle("Jogo")
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(0, 0, 0) -- Define a cor de fundo como preta
    
    -- Inicialização do jogador
    player.size = 30
    player.x = love.graphics.getWidth() / 2 - player.size / 2
    player.y = love.graphics.getHeight() / 2 - player.size / 2
    player.speed = 200
    
    -- Inicialização do inimigo
    enemy.size = 40
    enemy.x = love.math.random(0, love.graphics.getWidth() - enemy.size)
    enemy.y = love.math.random(0, love.graphics.getHeight() - enemy.size)
    enemy.speed = 100
    
    restartGame()
end

-- Função de tratamento de entrada do teclado
function love.keypressed(key)
    -- Reiniciar o jogo quando a tecla "R" for pressionada durante o estado de parabéns
    if key == "r" and congrats then
        restartGame()
        isPaused = false -- Despausar o jogo após reiniciar
    end
end

-- Função de atualização do jogo
function love.update(dt)
    -- Verificação de game over
    if gameover then
        if love.keyboard.isDown("r") then
            restartGame()
        end
        return -- Não atualiza o jogo se estiver no estado de game over
    end
    
    -- Verificação de pausa do jogo
    if love.keyboard.isDown("p") then
        isPaused = not isPaused
        love.timer.sleep(0.2) -- Pequeno atraso para evitar pressionar a tecla várias vezes
    end
    
    -- Atualização do jogador
    if not isPaused then
        -- Movimentação do jogador
        if love.keyboard.isDown("up") and player.y > 0 then
            player.y = player.y - player.speed * dt
        end
        if love.keyboard.isDown("down") and player.y < love.graphics.getHeight() - player.size then
            player.y = player.y + player.speed * dt
        end
        if love.keyboard.isDown("left") and player.x > 0 then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("right") and player.x < love.graphics.getWidth() - player.size then
            player.x = player.x + player.speed * dt
        end
        
        -- Movimentação do inimigo
        local dx = player.x - enemy.x
        local dy = player.y - enemy.y
        local distance = math.sqrt(dx * dx + dy * dy)
        local enemySpeed = enemy.speed * dt * 0.6 -- Velocidade reduzida para o inimigo
        
        if distance > enemySpeed then
            enemy.x = enemy.x + dx / distance * enemySpeed
            enemy.y = enemy.y + dy / distance * enemySpeed
        else
            lives = lives - 1 -- Desconta uma vida ao encostar no inimigo
            if lives <= 0 then
                gameover = true
            else
                -- Para o jogador temporariamente para descontar a vida
                player.x = love.graphics.getWidth() / 2 - player.size / 2
                player.y = love.graphics.getHeight() / 2 - player.size / 2
            end
        end
        
        -- Verificação de colisão com os itens coletáveis
        for i, item in ipairs(items) do
            if not item.collected and CheckCollision(player.x, player.y, player.size, player.size, item.x, item.y, item.size, item.size) then
                item.collected = true -- Marca o item como coletado
                score = score + 1
            end
        end
        
        -- Verificação de vitória ao coletar todos os itens
        if score == #items then
            congrats = true
            isPaused = true
        end
    end
end

-- Função de desenho do jogo
function love.draw()
    -- Desenho do jogador
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", player.x, player.y, player.size, player.size)
    
    -- Desenho do inimigo
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", enemy.x, enemy.y, enemy.size)
    
    -- Desenho dos itens coletáveis
    love.graphics.setColor(0, 255, 0)
    for _, item in ipairs(items) do
        if not item.collected then -- Desenha apenas os itens não coletados
            love.graphics.rectangle("fill", item.x, item.y, item.size, item.size)
        end
    end
    
    -- Desenho da pontuação
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Pontuação: " .. score, 10, 10)
    
    -- Desenho das vidas
    love.graphics.setColor(255, 0, 0)
    love.graphics.print("Vidas: " .. lives, 10, 30)
    
    -- Desenho da mensagem de game over
    if gameover then
        love.graphics.setColor(255, 0, 0)
        love.graphics.printf("Game Over\nPressione R para reiniciar", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    end
    
    -- Desenho da mensagem de parabéns
    if congrats then
        love.graphics.setColor(0, 255, 0)
        love.graphics.printf("Parabéns!\nVocê coletou todos os itens!\nPressione R para jogar novamente", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
    end
    
    -- Desenho da mensagem de pausa
    if isPaused and not gameover and not congrats then
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf("Jogo Pausado\nPressione P para continuar", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    end
end

-- Função de verificação de colisão entre dois retângulos
function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end
