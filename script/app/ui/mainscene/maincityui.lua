local MainCityUI = class("MainCityUI", BaseUI)
local openTypes = {
    [1] = 'arena',
    [2] = 'boat',
    [3] = 'blacksmith',
    [4] = 'pub',
    [5] = 'mail',
    [6] = 'tower',
    [7] = 'goldmine_enter',
    [8] = 'altar',
    [9] = 'statue',
    [10] = 'stable',
    [11] = 'shop',
    [12] = 'worldwar',
    [13] = 'train',
}

function MainCityUI:ctor(callback,stype,ntype,waitUIIndex)
	self.uiIndex = GAME_UI.UI_MAINCITY
    self.callback = callback
    self.panelTouchEnable = true
    self.ntype = ntype
    self.stype = stype -- 屏幕位置
    self.allPos = {}
    self.npcPos = nil
    self.waitUIIndex = waitUIIndex
end

function MainCityUI:getMainCity()
    return self.root
end

function MainCityUI:update()
    self:updateSigns()
end

function MainCityUI:onShow()
    UIManager:setBlockTouch(false)
    self:update()
    self:handAction()
    UIManager:showSidebar({1,2,4,5,6,7},{1,2,3},true)
end

function MainCityUI:openPanel(index)
    UIManager:setBlockTouch(false)
    GlobalApi:getGotoByModule(openTypes[index])
    self.panelTouchEnable = true
    self.panel1:setTouchEnabled(self.panelTouchEnable)
end

function MainCityUI:updateSigns()
    if self.newImgs then
        local signs = {
            UserData:getUserObj():getSignByType('arena'),
            UserData:getUserObj():getSignByType('boat'),
            UserData:getUserObj():getSignByType('blacksmith'),
            UserData:getUserObj():getSignByType('tavern'),
            UserData:getUserObj():getSignByType('mail'),
            UserData:getUserObj():getSignByType('tower'),
            UserData:getUserObj():getSignByType('goldmine_digging'),
            UserData:getUserObj():getSignByType('altar'),
            UserData:getUserObj():getSignByType('statue'),
            false,
            UserData:getUserObj():getSignByType('shop'),
            UserData:getUserObj():getSignByType('worldwar'),
            UserData:getUserObj():getSignByType('train'),
        }
        local open = {
            GlobalApi:getOpenInfo('arena'),
            GlobalApi:getOpenInfo('boat'),
            GlobalApi:getOpenInfo('blacksmith'),
            GlobalApi:getOpenInfo('pub'),
            true,
            GlobalApi:getOpenInfo('tower'),
            GlobalApi:getOpenInfo('goldmine'),
            GlobalApi:getOpenInfo('altar'),
            GlobalApi:getOpenInfo('statue'),
            false,
            GlobalApi:getOpenInfo('shop'),
            GlobalApi:getOpenInfo('worldwar'),
            GlobalApi:getOpenInfo('train'),
        }
        for i,v in ipairs(self.newImgs) do
            v:setVisible(signs[i] and open[i])
        end
    end
end

--- 更新金矿和挖矿
function MainCityUI:updateGoldMineDiggingSign()
    if self.newImgs then
        if self.newImgs[7]:isVisible() == false then
            local sign = UserData:getUserObj():getSignByType('goldmine_digging')
            local open = GlobalApi:getOpenInfo('goldmine')
            self.newImgs[7]:setVisible(sign and open)
            print('================++++++=====-------------99999')
        end      
    end
end

--- 更新玩法大厅
function MainCityUI:updateBoatSign()
    if self.newImgs then
        if self.newImgs[2]:isVisible() == false then
            local sign = UserData:getUserObj():getSignByType('boat')
            local open = GlobalApi:getOpenInfo('boat')
            self.newImgs[2]:setVisible(sign and open)
            print('================++++++=====-------------88888')
        end      
    end
end


function MainCityUI:createBuilding()
    local panel1 = self.root:getChildByName("Panel_1")
    local panel2 = panel1:getChildByName("Panel_2")
    local panel3 = panel2:getChildByName("Panel_3")
    local cityLandImg = panel3:getChildByName("main_city_land_img")
    local landImg1 = cityLandImg:getChildByName("land_1_img")

    landImg1:setLocalZOrder(2)
    local conf = GameData:getConfData("local/building")
    self.buildingPls = {}
    local buildingNameImgs = {
        'uires/ui/maincity/arena_tx_img.png',
        'uires/ui/maincity/tx_fb.png',
        'uires/ui/maincity/blacksmith_tx_img.png',
        'uires/ui/maincity/pub_tx_img.png',
        'uires/ui/maincity/email_tx_img.png',
        'uires/ui/maincity/tx_qct.png',
        'uires/ui/maincity/tx_jk.png',
        'uires/ui/maincity/altar_tx_img.png',
        'uires/ui/maincity/statue_tx_img.png',
        'uires/ui/maincity/shoulan_tx_img.png',
        'uires/ui/maincity/businessman_tx_img.png',
        'uires/ui/maincity/worldwar_tx_img.png',
        -- 'uires/ui/maincity/trainer_tx_img.png',
    }
    self.newImgs = {}
    for i=1,12 do
        local pl = cityLandImg:getChildByName('building_'..i..'_pl')
        local bgImg = pl:getChildByName('bg_img')
        self.newImgs[i] = pl:getChildByName('new_img')
        self.newImgs[i]:loadTexture('uires/ui/buoy/new_point.png')
        self.newImgs[i]:ignoreContentAdaptWithSize(true)
        self.buildingPls[#self.buildingPls + 1] = pl
        self.newImgs[i]:setLocalZOrder(9)
        pl:setSwallowTouches(false)
        pl:setLocalZOrder(10)
        if bgImg then
            bgImg:setScale(1.2)
            bgImg:setLocalZOrder(1)
            local txImg = bgImg:getChildByName('tx_img')
            bgImg:loadTexture('uires/ui/maincity/building_bg.png')
            local size = bgImg:getContentSize()
            local lockImg = ccui.ImageView:create('uires/ui/guard/lock.png')
            lockImg:setScale(0.7)
            lockImg:setPosition(cc.p(size.width/2 + 5,0))
            lockImg:setName('lock_img')
            bgImg:addChild(lockImg)
            txImg:loadTexture(buildingNameImgs[i])
            bgImg:ignoreContentAdaptWithSize(true)
            txImg:ignoreContentAdaptWithSize(true)
            if i == 10 then
                bgImg:setVisible(false)
            end
        end
    end
    self.buildings = {}
    for i,v in ipairs(conf) do
        local plPos = cc.p(self.buildingPls[v.pos]:getPositionX(),self.buildingPls[v.pos]:getPositionY())
        self.allPos[v.url] = plPos
        self.buildingPls[v.pos]:setLocalZOrder(v.zorder)
        local url = 'spine/city_building/'.. v.url
        self.buildings[v.pos] = GlobalApi:createSpineByName(v.url, url, 1)
        local size = self.buildingPls[v.pos]:getContentSize()
        self.buildings[v.pos]:setPosition(cc.p(size.width/2,0))
        self.buildingPls[v.pos]:addChild(self.buildings[v.pos])
        self.buildings[v.pos]:setScale(v.scale*0.77)
        local action = 'idle'
        self.buildings[v.pos]:registerSpineEventHandler(function (event)
            local hadNewMail = UserData:getUserObj():getHadNewMail()
            action = ((hadNewMail == true and v.pos == 5) and 'idle_youjian') or 'idle'
            self.buildings[v.pos]:setAnimation(0, action, false)
        end, sp.EventType.ANIMATION_COMPLETE)

        self.buildings[v.pos]:registerSpineEventHandler(function (event)
            if event.animation == 'idle2' or event.animation == 'idle2_youjian' then
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
                    self:openPanel(v.pos)
                end)))
            end
        end, sp.EventType.ANIMATION_END)

        local bgImg = self.buildingPls[v.pos]:getChildByName('bg_img')
        if bgImg then
            local lockImg = bgImg:getChildByName('lock_img')
            local isOpen = GlobalApi:getOpenInfo(openTypes[v.pos])
            lockImg:setVisible(not isOpen)
        end

        local point1
        local point2
        self.buildingPls[v.pos]:addTouchEventListener(function (sender, eventType)
            if v.url == 'stable' then
                return
            end
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                point1 = sender:getTouchBeganPosition()
            end
            if eventType == ccui.TouchEventType.ended then
                point2 = sender:getTouchEndPosition()
                if point1 then
                    local dis =cc.pGetDistance(point1,point2)
                    if self.panelTouchEnable == false or dis <= 50 then
                        local hadNewMail = UserData:getUserObj():getHadNewMail()
                        action = ((hadNewMail == true and v.pos == 5) and 'idle2_youjian') or 'idle2'
                        self.buildings[v.pos]:setAnimation(0, action, false)
                        UIManager:setBlockTouch(true)
                    end
                end
            end
        end)
        local hadNewMail = UserData:getUserObj():getHadNewMail() or false
        action = ((hadNewMail == true and v.pos == 5) and 'idle_youjian') or 'idle'
        self.buildings[v.pos]:setAnimation(0, action, false)
    end
end

function MainCityUI:monsterMove(pl,npc,npos)
    local posX,posY = npos.x,npos.y
    local pos = {cc.p(posX - 200,posY),cc.p(posX,posY),cc.p(posX + 200,posY)}
    local function getRandom()
        repeat
            local random =math.random(1,3)
            if random == self.random then
                self.random = random %3 + 1
                return
            else
                self.random = random
                return
            end
        until false
    end
    getRandom()
    local posX1 = pos[self.random].x
    local currPosX = pl:getPositionX()
    local time = math.abs(currPosX - posX1)/100
    if currPosX < posX1 then
        npc:setScaleX(math.abs(npc:getScaleX()))
    else
        npc:setScaleX(-math.abs(npc:getScaleX()))
    end

    npc:setAnimation(0,'walk', false)
    pl:runAction(cc.Sequence:create(
        cc.MoveTo:create(time,cc.p(posX1,posY)),
        cc.CallFunc:create(function()
            npc:setAnimation(0,'idle', false)
        end),
        cc.DelayTime:create(math.random(3,5)),
        cc.CallFunc:create(function()
            self:monsterMove(pl,npc,npos)
        end)
    ))
end

function MainCityUI:createNPC()
    local pl = self.cityLandImg:getChildByName('building_13_pl')
    self.newImgs[13] = pl:getChildByName('new_img')
    self.newImgs[13]:loadTexture('uires/ui/buoy/new_point.png')
    self.newImgs[13]:ignoreContentAdaptWithSize(true)
    self.newImgs[13]:setLocalZOrder(9)
    local npc = GlobalApi:createSpineByName("train", "spine/city_building/train", 1)
    npc:setScale(0.77)
    local size = pl:getContentSize()
    npc:setName('train')
    npc:setPosition(cc.p(size.width/2,0))
    -- npc:setName('train')
    pl:addChild(npc)
    pl:setLocalZOrder(9)

    npc:registerSpineEventHandler(function (event)
        if event.animation == 'walk' then
            npc:setAnimation(0, 'walk', false)
        else
            npc:setAnimation(0, 'idle', false)
        end
    end, sp.EventType.ANIMATION_COMPLETE)

    npc:registerSpineEventHandler(function (event)
        if event.animation == 'idle2' then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
                self:openPanel(13)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function( )
                local pos = cc.p(pl:getPositionX(),pl:getPositionY())
                self:monsterMove(pl,npc,pos)
            end)
            ))
        end
    end, sp.EventType.ANIMATION_END)

    local point1
    local point2
    pl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            point1 = sender:getTouchBeganPosition()
        end
        if eventType == ccui.TouchEventType.ended then
            point2 = sender:getTouchEndPosition()
            if point1 then
                local dis =cc.pGetDistance(point1,point2)
                if self.panelTouchEnable == false or dis <= 50 then
                    npc:setAnimation(0, 'idle2', false)
                    pl:stopAllActions()
                    UIManager:setBlockTouch(true)
                end
            end
        end
    end)
    npc:setAnimation(0, 'idle', false)
    
    local pos = cc.p(pl:getPositionX(),pl:getPositionY())
    self:monsterMove(pl,npc,pos)
end

function MainCityUI:createFly1(animal1)
    local size = self.cityMountainImg:getContentSize()
    local index = math.random(1,2)
    local height = size.height - math.random(110,180)
    local beginPos = {
        cc.p(-100,height),
        cc.p(size.width + 100,height),
    }
    local endPos = {
        cc.p(size.width + 100,height),
        cc.p(-100,height),
    }
    animal1:setPosition(cc.p(beginPos[index]))
    if beginPos[index].x < endPos[index].x then
        animal1:setScaleX(-math.abs(animal1:getScaleX()))
    else
        animal1:setScaleX(math.abs(animal1:getScaleX()))
    end
    local time = math.abs(endPos[index].x - beginPos[index].x)/math.random(80,120)
    animal1:runAction(cc.Sequence:create(
        cc.DelayTime:create(math.random(5,8)),
        cc.MoveTo:create(time,endPos[index]),
        cc.CallFunc:create(function()
            self:createFly1(animal1)
        end)
        ))
end

function MainCityUI:createFly2(animal2)
    local size = self.cityMountainImg:getContentSize()
    local index = math.random(1,3)
    local beginPos = {
        cc.p(size.width/2 + math.random(-50,50),0),
        cc.p(size.width/2 + math.random(50,150),0),
        cc.p(size.width/2 + math.random(150,250),0)
    }
    local endPos = {
        cc.p(-100,size.height - math.random(50,120)),
        cc.p(size.width/2 - math.random(450,550),size.height + 100),
        cc.p(size.width + 100,size.height - math.random(100,180))
    }
    animal2:setPosition(cc.p(beginPos[index]))
    local time = math.abs(endPos[index].x - beginPos[index].x)/math.random(80,120)
    animal2:runAction(cc.Sequence:create(
        cc.DelayTime:create(math.random(5,8)),
        cc.MoveTo:create(time,endPos[index]),
        cc.CallFunc:create(function()
            self:createFly2(animal2)
        end)
        ))
end

function MainCityUI:createPubu()
    local pubu1 = GlobalApi:createLittleLossyAniByName('scene_tx_pubu_01')
    pubu1:setPosition(cc.p(1750,280))
    -- pubu1:setPosition(cc.p(1745,275))
    pubu1:getAnimation():playWithIndex(0, -1, 1)
    self.cityMountainImg:addChild(pubu1)
    pubu1:setScaleY(1.2)

    local pubu2 = GlobalApi:createLittleLossyAniByName('scene_tx_pubu_02')
    pubu2:setPosition(cc.p(1288,335))
    pubu2:getAnimation():playWithIndex(0, -1, 1)
    self.cityMountainImg:addChild(pubu2)

    local size = self.cityMountainImg:getContentSize()
    local animal1 = GlobalApi:createSpineByName('mainscene_animal_1', "spine/mainscene_animal_1/mainscene_animal_1", 1)
    animal1:setAnchorPoint(cc.p(0.5,0))
    animal1:setPosition(cc.p(size.width/2,0))
    animal1:setAnimation(0, 'fly', true)
    self.cityMountainImg:addChild(animal1)

    local animal2 = GlobalApi:createSpineByName('mainscene_animal_2', "spine/mainscene_animal_2/mainscene_animal_2", 1)
    animal2:setAnchorPoint(cc.p(0.5,0))
    animal2:setPosition(cc.p(size.width/2,0))
    animal2:setAnimation(0, 'fly', true)
    self.cityMountainImg:addChild(animal2)

    local animal3 = GlobalApi:createSpineByName('mainscene_animal_3', "spine/mainscene_animal_3/mainscene_animal_3", 1)
    animal3:setAnchorPoint(cc.p(0.5,0))
    animal3:setPosition(cc.p(953,176))
    animal3:setAnimation(0, 'idle', true)
    self.cityMountainImg:addChild(animal3)

    local penquan = GlobalApi:createLittleLossyAniByName('scene_tx_penquan_01')
    penquan:setScale(1)
    penquan:setAnchorPoint(cc.p(0,0))
    penquan:setPosition(cc.p(3350,220))
    penquan:getAnimation():playWithIndex(0, -1, 1)
    self.cityLandImg:addChild(penquan,2)

    local shuiwen = GlobalApi:createLittleLossyAniByName('scene_tx_shuiwen_01')
    shuiwen:setScale(2.6)
    shuiwen:setAnchorPoint(cc.p(0,0))
    shuiwen:setPosition(cc.p(0,0))
    shuiwen:getAnimation():playWithIndex(0, -1, 1)
    self.cityLandImg:addChild(shuiwen)

    self:createFly1(animal1)
    self:createFly2(animal2)
end

-- ntype 是否直接定位
-- 定位
function MainCityUI:setWinPosition(stype,lock)
    print(stype)
    local pos = self.allPos[stype]
    if stype == 'train' then
        local pl = self.cityLandImg:getChildByName('building_13_pl')
        local npc = pl:getChildByName('train')
        if npc then
            npc:setAnimation(0, 'idle', false)
        end
        pl:stopAllActions()
        pos = cc.p(pl:getPositionX(),pl:getPositionY())
    end
    
    local winSize = cc.Director:getInstance():getVisibleSize()
    local pos1 = pos.x - winSize.width/2
    local posX,posY = winSize.width/2 - pos.x*self.scale,self.imgs[1]:getPositionY()
    local point = cc.p(posX*0.83,posY*0.83)
    self:detectEdges(1,point)
    local per = (point.x - self.limitLWs[1])/(self.limitRWs[1] - self.limitLWs[1])
    self.imgs[1]:setPosition(point)
    for i=2,6 do
        local posX,posY = (self.limitRWs[i] - self.limitLWs[i]) * per + self.limitLWs[i],self.imgs[i]:getPositionY()
        local point = cc.p(posX,posY)
        self:detectEdges(i,point)
        self.imgs[i]:setPosition(point)
    end
    if lock then
        self.panelTouchEnable = false
        self.panel1:setTouchEnabled(self.panelTouchEnable)
    end
end
--边界检测
function MainCityUI:detectEdges( i,point )
    if point.x > self.limitRWs[i] then
        point.x = self.limitRWs[i]
    end
    if point.x < self.limitLWs[i] then
        point.x = self.limitLWs[i]
    end
    if point.y > self.limitUHs[i] then
        point.y = self.limitUHs[i]
    end
    if point.y < self.limitDHs[i] then
        point.y = self.limitDHs[i]
    end
end

function MainCityUI:initCity()
    local panel1 = self.root:getChildByName("Panel_1")
    local panel2 = panel1:getChildByName("Panel_2")
    local panel3 = panel2:getChildByName("Panel_3")
    local cityCloudImg = panel3:getChildByName("main_city_cloud_img")
    cityCloudImg:loadTexture('uires/ui/maincity/main_city_cloud_01.png')
    cityCloudImg:ignoreContentAdaptWithSize(true)
    self.panel1 = panel1

    local cityMountainImg = panel3:getChildByName("main_city_mountain_img")
    cityMountainImg:loadTexture('uires/ui/maincity/main_city_mountain_01.png')
    cityMountainImg:ignoreContentAdaptWithSize(true)
    self.cityMountainImg = cityMountainImg

    local cityMountainImg1 = panel3:getChildByName("main_city_mountain_1_img")
    -- cityMountainImg1:loadTexture('uires/ui/maincity/main_city_house_02.png')
    -- cityMountainImg1:ignoreContentAdaptWithSize(true)
    cityMountainImg1:setVisible(false)

    local cityHouseImg = panel3:getChildByName("main_city_house_img")
    -- local houseImg = cityHouseImg:getChildByName("house_img")
    cityHouseImg:loadTexture('uires/ui/maincity/main_city_house_01.png')
    -- houseImg:loadTexture('uires/ui/maincity/main_city_house_02.png')
    cityHouseImg:ignoreContentAdaptWithSize(true)
    -- houseImg:ignoreContentAdaptWithSize(true)

    local cityLandImg = panel3:getChildByName("main_city_land_img")
    local cityLandImg1 = cityLandImg:getChildByName("land_1_img")
    local cityLandImg2 = cityLandImg:getChildByName('land_2_img')
    self.cityLandImg = cityLandImg
    self.cityLandImg1 = cityLandImg1
    self.cityLandImg2 = cityLandImg2
    cityLandImg:loadTexture('uires/ui/maincity/main_city_land_01.png')
    cityLandImg1:loadTexture('uires/ui/maincity/main_city_land_02.png')
    cityLandImg2:loadTexture('uires/ui/maincity/main_city_land_03.png')
    cityLandImg:ignoreContentAdaptWithSize(true)
    cityLandImg1:ignoreContentAdaptWithSize(true)
    cityLandImg2:ignoreContentAdaptWithSize(true)

    local cityShadowImg = panel3:getChildByName("main_city_shadow_img")
    local cityShadowImg1 = cityShadowImg:getChildByName("main_city_shadow_1_img")
    cityShadowImg:loadTexture('uires/ui/maincity/main_city_shadow.png')
    cityShadowImg:ignoreContentAdaptWithSize(true)
    cityShadowImg1:loadTexture('uires/ui/maincity/main_city_shadow.png')
    cityShadowImg1:ignoreContentAdaptWithSize(true)
    local winSize = cc.Director:getInstance():getVisibleSize()
    
    local houseSize = 400 + 1200
    local mountainSize1 = 400 + 500
    local shadowSize = 500
    local width1 = (cityLandImg:getContentSize().width + cityLandImg1:getContentSize().width + cityLandImg2:getContentSize().width)*0.83 -- 0,0
    local width2 = cityCloudImg:getContentSize().width -- 0.5,1
    local width3 = cityMountainImg:getContentSize().width -- 0,1
    local width5 = cityMountainImg1:getContentSize().width -- 0,1
    -- local width4 = cityHouseImg:getContentSize().width + houseImg:getContentSize().width + houseSize -- 0,1
    local width4 = cityHouseImg:getContentSize().width + houseSize -- 0,1
    local height1 = 768
    local scale = winSize.height/768
    cityLandImg:setScale(scale*0.83)
    cityCloudImg:setScale(scale)
    cityMountainImg:setScale(scale)
    cityHouseImg:setScale(scale)
    cityShadowImg:setScale(scale)
    cityMountainImg1:setScale(scale)

    local limitLW = winSize.width - width1*scale
    local limitRW,limitUH,limitDH = 0,0,0

    local limitLW1 = winSize.width - width2*scale*0.5
    local limitRW1 = width2*scale*0.5
    local limitUH1,limitDH1 = winSize.height,winSize.height

    local limitLW2 = winSize.width - width3*scale
    local limitRW2 = 0
    local limitUH2,limitDH2 = winSize.height,winSize.height

    local limitLW5 = winSize.width
    local limitRW5 = width1*scale- mountainSize1
    local limitUH5,limitDH5 = winSize.height*13.5/15,winSize.height*13.5/15

    local limitLW3 = winSize.width - 700
    local limitRW3 = width1*scale- houseSize
    local limitUH3,limitDH3 = winSize.height*15/15,winSize.height*15/15

    local limitLW4 = winSize.width
    local limitRW4 = width1*scale- shadowSize
    local limitUH4,limitDH4 = 0,0

    local abs1 = math.abs(limitLW - limitRW)
    local abs2 = math.abs(limitLW1 - limitRW1)
    local abs3 = math.abs(limitLW2 - limitRW2)
    local abs4 = math.abs(limitLW3 - limitRW3)
    local abs5 = math.abs(limitLW4 - limitRW4)
    local abs6 = math.abs(limitLW5 - limitRW5)

    -- cityLandImg:setPosition(cc.p(-width1*scale/2 + winSize.width/2,0))
    -- cityCloudImg:setPosition(cc.p(winSize.width/2,winSize.height))
    -- cityMountainImg:setPosition(cc.p(-width3*scale/2 + winSize.width/2,winSize.height))
    -- cityMountainImg1:setPosition(cc.p(width1*scale/2 + winSize.width/2 - mountainSize1/2,winSize.height*12/15))
    -- cityHouseImg:setPosition(cc.p(width1*scale/2 + winSize.width/2 - houseSize/2,winSize.height*12/15))
    -- cityShadowImg:setPosition(cc.p(width1*scale/2 + winSize.width/2 - shadowSize/2,0))

    self.limitLWs = {limitLW,limitLW1,limitLW2,limitLW3,limitLW4,limitLW5}
    self.limitRWs = {limitRW,limitRW1,limitRW2,limitRW3,limitRW4,limitRW5}
    self.limitUHs = {limitUH,limitUH1,limitUH2,limitUH3,limitUH4,limitUH5}
    self.limitDHs = {limitDH,limitDH1,limitDH2,limitDH3,limitDH4,limitDH5}
    self.abs = {abs1,abs2,abs3,abs4,abs5,abs6}
    self.imgs = {cityLandImg,cityCloudImg,cityMountainImg,cityHouseImg,cityShadowImg,cityMountainImg1}
    self.scale = scale

    local function onKeyboardPressed(keyCode,event)
        if tonumber(keyCode) == 140 then
            -- SocketMgr:close()
            -- UIManager:closeAllUI()
            -- UserData:removeAllData()
            -- LoginMgr:showLogin()
            -- LoginMgr:showCreateName()
			UIManager:backToLogin()
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyboardPressed,cc.Handler.EVENT_KEYBOARD_PRESSED)
    local eventDispatcher1 = self.root:getEventDispatcher()
    eventDispatcher1:addEventListenerWithSceneGraphPriority(listener, self.root)

    local bgPanelPrePos = nil
    local bgPanelPos = nil
    local bgPanelDiffPos = nil
    panel1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            bgPanelPrePos = bgPanelPos
            bgPanelPos = sender:getTouchMovePosition()
            if bgPanelPrePos then
                bgPanelDiffPos = cc.p(bgPanelPos.x - bgPanelPrePos.x, bgPanelPos.y - bgPanelPrePos.y)
                local targetPos = cc.pAdd(cc.p(cityLandImg:getPositionX(),cityLandImg:getPositionY()),bgPanelDiffPos)
                local targetPos1 = cc.pAdd(cc.p(cityCloudImg:getPositionX(),cityCloudImg:getPositionY()),cc.p(bgPanelDiffPos.x*abs2/abs1,0))
                local targetPos2 = cc.pAdd(cc.p(cityMountainImg:getPositionX(),cityMountainImg:getPositionY()),cc.p(bgPanelDiffPos.x*abs3/abs1,0))
                local targetPos3 = cc.pAdd(cc.p(cityHouseImg:getPositionX(),cityHouseImg:getPositionY()),cc.p(bgPanelDiffPos.x*abs4/abs1,0))
                local targetPos4 = cc.pAdd(cc.p(cityShadowImg:getPositionX(),cityShadowImg:getPositionY()),cc.p(bgPanelDiffPos.x*abs5/abs1,0))
                local targetPos5 = cc.pAdd(cc.p(cityMountainImg1:getPositionX(),cityMountainImg1:getPositionY()),cc.p(bgPanelDiffPos.x*abs6/abs1,0))
                self:detectEdges(1,targetPos)
                self:detectEdges(2,targetPos1)
                self:detectEdges(3,targetPos2)
                self:detectEdges(4,targetPos3)
                self:detectEdges(5,targetPos4)
                self:detectEdges(6,targetPos5)
                cityLandImg:setPosition(targetPos)
                cityCloudImg:setPosition(targetPos1)
                cityMountainImg:setPosition(targetPos2)
                cityHouseImg:setPosition(targetPos3)
                cityShadowImg:setPosition(targetPos4)
                cityMountainImg1:setPosition(targetPos5)
            end
        else
            bgPanelPrePos = nil
            bgPanelPos = nil
            bgPanelDiffPos = nil
            if eventType == ccui.TouchEventType.began then
            elseif eventType == ccui.TouchEventType.ended then
            end
        end
    end)

    self.fightBtn = panel1:getChildByName('fight_btn')
    self.fightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:printScreen()
        end
    end)

    -- local militaryBtn = panel1:getChildByName('military_btn')
    -- militaryBtn:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         MainSceneMgr:showMilitary()
    --     end
    -- end)
    -- local size = militaryBtn:getContentSize()
    -- militaryBtn:setPosition(cc.p(winSize.width - size.width/2,winSize.height - size.height*1.5))

    self:createBuilding()
    self:setWinPosition(self.stype or 'arena')
    self:handAction()
    self:createNPC()
    self:createPubu()
    self:update()
    -- if self:isOnTop() then
    --     UIManager:showSidebar({1,2,3,4,6,7},{1,2,3},true,true)
    -- end
    -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
    --     if self:isOnTop() then
            UIManager:showSidebar({1,2,4,5,6,7},{1,2,3},true)
    --     end
    -- end)))
    -- if self.ntype and GuideMgr:isRunning() ~= true and isOpen then
    --     local diffTime = GlobalData:getServerTime() - MapData.patrol
    --     if diffTime > tonumber(GlobalApi:getGlobalValue('patrolMaxTime')) then
    --         diffTime = tonumber(GlobalApi:getGlobalValue('patrolMaxTime'))
    --     end
    --     if diffTime > tonumber(GlobalApi:getGlobalValue('patrolInterval')) * 60 * 6 then
    --         local args = {}
    --         MessageMgr:sendPost('patrol_get_award','battle',json.encode(args),function (response)
    --             
    --             local code = response.code
    --             local data = response.data
    --             if code == 0 then
    --                 local awards = data.awards
    --                 local gold_xp = data.gold_xp
    --                 if #awards > 0 then
    --                     MapMgr:showPatrolAwardsPanel(awards)
    --                 end
    --                 GlobalApi:parseAwardData(awards)
    --                 GlobalApi:parseAwardData(gold_xp)
    --                 local costs = data.costs
    --                 if costs then
    --                     GlobalApi:parseAwardData(costs)
    --                 end
    --                 MapData.patrol = data.patrol or MapData.patrol
    --             end
    --         end)
    --     end
    -- else
        -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
            if self.callback then
                self.callback()
            end
        -- end)))
    -- end
    self:addCustomEventListener(CUSTOM_EVENT.GUIDE_FINISH,function()
        if self:isOnTop() then
            UIManager:showSidebar({1,2,4,5,6,7},{1,2,3},true)
        end
    end)
    self:addCustomEventListener(CUSTOM_EVENT.GUIDE_START,function()
        self:handAction(true)
    end)
end

function MainCityUI:handAction(b)
    local panel1 = self.root:getChildByName("Panel_1")
    local level = UserData:getUserObj():getLv()
    local guideImg = panel1:getChildByName('guide_img')
    local size = self.fightBtn:getContentSize()
    if not guideImg then
        guideImg = ccui.ImageView:create('uires/ui/maincity/new.png')
        guideImg:setPosition(cc.p(size.width*3/4,size.height))
        panel1:addChild(guideImg)
        guideImg:setName('guide_img')
        guideImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2),cc.DelayTime:create(0.5),cc.FadeIn:create(2))))
        guideImg:setCascadeOpacityEnabled(true)

        local descTx = ccui.Text:create()
        descTx:setFontName("font/gamefont1.TTF")
        descTx:setFontSize(24)
        descTx:setPosition(cc.p(size.width/2 - 5,43))
        descTx:setTextColor(COLOR_TYPE.WHITE)
        descTx:enableOutline(cc.c3b(146,58,5), 1)
        descTx:setAnchorPoint(cc.p(0.5,0.5))
        descTx:setName('desc_tx')
        guideImg:addChild(descTx)
    end
    local descTx = guideImg:getChildByName('desc_tx')
    guideImg:setVisible(false)
    if not b and level <= 15 and GuideMgr:isRunning() ~= true then
        guideImg:setVisible(true)
        descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_1'))
    elseif not b and level <= 25 and GuideMgr:isRunning() ~= true then
        guideImg:setVisible(true)
        descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_2'))
    elseif MapMgr.thief then
        local hadThief = false
        local nowTime = GlobalData:getServerTime()
        local conf = GameData:getConfData("thief")
        for k,v in pairs(MapMgr.thief) do
            local thiefConf = conf[tonumber(v.id)]
            local beginTime = tonumber(v.time)
            local diffTime = beginTime + tonumber(thiefConf.liveTime)*60 - GlobalData:getServerTime()
            if diffTime > 0 then
                hadThief = true
                break
            end
        end
        if hadThief then
            guideImg:setVisible(true)
            descTx:setString(GlobalApi:getLocalStr('MAIN_CITY_DESC_3'))
        end
    end
end

function MainCityUI:printScreen()
     print(socket.gettime())
     -- local winSize = cc.Director:getInstance():getVisibleSize()
     -- local screen = cc.RenderTexture:create(winSize.width, display.height)
     -- -- local maincity = MainSceneMgr:getMainCity()
     -- screen:retain()
     -- screen:begin()
     -- self.root:visit()
     -- -- self.root:visit()
     -- screen:endToLua()
     -- screen:setScale(0.999)
     -- screen:setAnchorPoint(0.5,0.5)
     -- screen:setPosition(cc.p(winSize.width/2,winSize.height/2))
     -- self.root:addChild(screen,1)

     UIManager:runLoadingAction(nil,function()
        MainSceneMgr:hideMainCity()
        -- MapMgr:showMainScene(2,nil,nil,0.4)
        MapMgr:showMainScene(2,nil,nil,nil,true,function()
            UIManager:removeLoadingAction()
        end)
        -- screen:removeFromParent()
    end)
end

function MainCityUI:loadingTexture()
    local loadingUI = UIManager:getLoadingUI()
    loadingUI:setPercent(0)
    local loadedImgCount = 0
    local loadedImgMaxCount = 39
    local function imageLoaded()
        loadedImgCount = loadedImgCount + 1
        local loadingPercent = (loadedImgCount/loadedImgMaxCount)*90
        loadingUI:setPercent(loadingPercent)
        if loadedImgCount >= loadedImgMaxCount then
            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
                loadingUI:runToPercent(0.2, 100, function ()
                    if self.waitUIIndex then
                        self:addCustomEventListener(CUSTOM_EVENT.UI_SHOW, function (uiIndex)
                            if uiIndex == self.waitUIIndex then
                                self:removeCustomEventListener(CUSTOM_EVENT.UI_SHOW)
                                self.waitUIIndex = nil
                                UIManager:hideLoadingUI()
                            end
                        end)
                    else
                        UIManager:hideLoadingUI()
                    end
                    self:initCity()
                end)
            end)))
        end
    end
    UserData:getUserObj():getMainCityInfo(imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/arena_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/tx_fb.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/blacksmith_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/pub_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/email_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/tx_qct.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/tx_jk.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/trainer_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/businessman_tx_img.png',imageLoaded) 
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/altar_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/rank_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/shoulan_tx_img.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/worldwar_tx_img.png',imageLoaded)

    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/building_bg.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/cash.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/food.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/res/gold.png',imageLoaded)

    GlobalApi:createSpineAsyncByName('arena','spine/city_building/arena', imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_house_01.png',imageLoaded)
    GlobalApi:createSpineAsyncByName('blacksmith','spine/city_building/blacksmith', imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_house_02.png',imageLoaded)
    GlobalApi:createSpineAsyncByName('boat','spine/city_building/boat', imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_land_01.png',imageLoaded)
    GlobalApi:createSpineAsyncByName('email','spine/city_building/email', imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_land_02.png',imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_land_03.png',imageLoaded)
    GlobalApi:createSpineAsyncByName('altar','spine/city_building/altar', imageLoaded)
    GlobalApi:createSpineAsyncByName('stable','spine/city_building/stable', imageLoaded)
    GlobalApi:createSpineAsyncByName('statue','spine/city_building/statue', imageLoaded)
    GlobalApi:createSpineAsyncByName('goldmine','spine/city_building/goldmine', imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_mountain_01.png',imageLoaded)
    GlobalApi:createSpineAsyncByName('pub','spine/city_building/pub', imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_cloud_01.png',imageLoaded)
    GlobalApi:createSpineAsyncByName('tower','spine/city_building/tower', imageLoaded)
    cc.Director:getInstance():getTextureCache():addImageAsync('uires/ui/maincity/main_city_shadow.png',imageLoaded)
    GlobalApi:createSpineAsyncByName('altar','spine/city_building/altar', imageLoaded)
    GlobalApi:createSpineAsyncByName('stable','spine/city_building/stable', imageLoaded)
    GlobalApi:createSpineAsyncByName('statue','spine/city_building/statue', imageLoaded)
end

function MainCityUI:init()
    if self.ntype then
        self:initCity()
    else
        self:loadingTexture()
    end
end

return MainCityUI