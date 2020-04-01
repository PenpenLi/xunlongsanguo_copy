local TavernAnimateUI = class('TavernAnimateUI', BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')

-- fucking old log 
local heroFrame = {
	[2] = 'uires/ui/common/card_green.png',
	[3] = 'uires/ui/common/card_blue.png',
	[4] = 'uires/ui/common/card_purple.png',
	[5] = 'uires/ui/common/card_yellow.png',
	[6] = 'uires/ui/common/card_red.png',
	[7] = 'uires/ui/common/card_gold.png',
}

local heroCircle = {
	[1] = 'uires/ui/tavern/circle_gray.png',
	[2] = 'uires/ui/tavern/circle_green.png',
	[3] = 'uires/ui/tavern/circle_blue.png',
	[4] = 'uires/ui/tavern/circle_puple.png',
	[5] = 'uires/ui/tavern/circle_yellow.png',
	[6] = 'uires/ui/tavern/circle_red.png',
}

-- 示例图大小
local defaultSize = cc.size(960, 640)
local positions = {
	[1] = cc.p(185, 303),
	[2] = cc.p(298, 459),
	[3] = cc.p(473, 505),
	[4] = cc.p(657, 506),
	[5] = cc.p(833, 457),
	[6] = cc.p(954, 303),
	[7] = cc.p(772, 206),
	[8] = cc.p(568, 230),
	[9] = cc.p(359, 212),
	[10] = cc.p(570, 384)
}

-- 招募音效ID
local recruitAudioId = nil

function TavernAnimateUI:ctor(awards, func, recuitetype)
	self.uiIndex = GAME_UI.UI_TAVERN_ANIMATE
	self.awards = awards
	self.func = func
	-- self.isTen = isTen
	-- self.isTen = isTen
	self.curCards = 0
	self.cardsPositions = {}
	-- self.camera = nil

	self.cards = {}
	self.recuitetype = recuitetype
end

-- function TavernAnimateUI:onShow()
-- 	self.camera:setDepth(1)
-- end

-- function TavernAnimateUI:onCover()
-- 	self.camera:setDepth(-1)
-- end

function TavernAnimateUI:init()
	-- init camera 2
	-- self.camera = UIManager:createCamera()
	-- self.camera:setDepth(1)
	-- self.root:addChild(camera)

	local bg = self.root:getChildByName('tavern_bg')
	local mask_bg = bg:getChildByName('mask_bg')
	local winSize = cc.Director:getInstance():getWinSize()
	self.mask_bg = mask_bg
	self:adaptUI(bg, mask_bg, true)

	local againBtn = mask_bg:getChildByName('again_btn')
	againBtn:setLocalZOrder(9999)
	againBtn:addClickEventListener(function (  )
			self:func()
			TavernMgr:hideTavernAnimate()
			if self.role ~= nil then
				self.role:stopSound('sound')
			end
            if self.recuitetype == 1 then
                TavernMgr:recuit(self.recuitetype)
            else
                --TavernMgr:recuitTen(self.recuitetype)
                if tonumber(TavernMgr:getLuck()) == 1 then
                    if self.recuitetype == 3 then
		  			    TavernMgr:showTavernMasterUI(function (a)
		  				    TavernMgr:recuitTen(self.recuitetype,a)
		  			    end)
                    elseif self.recuitetype == 2 then
                        TavernMgr:recuitTen(self.recuitetype)
                    end
		  		else
		  			TavernMgr:recuit(self.recuitetype)
		  		end
            end
			
		end)
	local againTx = againBtn:getChildByName('text')
	local godieBtn = mask_bg:getChildByName('godie_btn')
	local backTx = godieBtn:getChildByName('text')
	backTx:setString(GlobalApi:getLocalStr('STR_RETURN_1'))
	godieBtn:setLocalZOrder(9999)
	godieBtn:addClickEventListener(function ()
			self:func()
			TavernMgr:hideTavernAnimate()
			if self.role ~= nil then
				self.role:stopSound('sound')
			end
		end)
	self.againBtn = againBtn
	self.godieBtn = godieBtn

	-- adapt position y
	local adapt_y = (bg:getContentSize().height - winSize.height) / 2 + 50
	againBtn:setPositionY(adapt_y)
	godieBtn:setPositionY(adapt_y)

	local sz = bg:getContentSize()
	if self.recuitetype == 3 then
		againTx:setString(GlobalApi:getLocalStr('TEN_MORE'))
		UIManager:showSidebar({1},{3,5,4},true)
		againBtn:setVisible(false)
		godieBtn:setVisible(false)
	elseif self.recuitetype == 4 then   -- sp...
		againBtn:setVisible(false)
		godieBtn:setPositionX(sz.width / 2)
		godieBtn:setVisible(true)
    	-- 烟花爆竹
		math.randomseed(os.clock()*10000)
		local num = math.random(3,4)
		mask_bg:setCascadeOpacityEnabled(false)
		mask_bg:setOpacity(100)
		local black_bg = ccui.ImageView:create()
	    black_bg:loadTexture('uires/ui/tavern/background.png')
	    black_bg:setScale9Enabled(true)
	    black_bg:setContentSize(sz)
	    black_bg:setTouchEnabled(true)
	    black_bg:setPosition(cc.p(sz.width / 2, sz.height / 2))
		self.mask_bg:addChild(black_bg,1)
		for i=1,num do
			local totaldelaytime = 0
			local delaytime = math.random(1,3)
			totaldelaytime = totaldelaytime + 1/delaytime						
			self.mask_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(totaldelaytime),cc.CallFunc:create(
				function ()
					local winSize = cc.Director:getInstance():getWinSize()
					local scale = math.random(1,2)
					local list = math.random(1,5)
					local particle = cc.ParticleSystemQuad:create("particle/ui_tavern_fireworks_"..list..".plist")
					particle:setAutoRemoveOnFinish(true)
					local posx = math.random(0,winSize.width)
					local posy = math.random(200,winSize.height+200)
					particle:setPosition(cc.p(posx,posy))
					particle:setScale(scale)
					self.mask_bg:addChild(particle,1)
				end))))
		end
		self:goAction()
		return
	else
		againTx:setString(GlobalApi:getLocalStr('ONCE_MORE'))
		UIManager:showSidebar({1},{3,5,4},true)
	end

    local black_bg = ccui.ImageView:create()
    black_bg:loadTexture('uires/ui/common/bg_black.png')
    black_bg:setScale9Enabled(true)
    black_bg:setContentSize(sz)
    black_bg:setTouchEnabled(true)
    black_bg:setPosition(cc.p(sz.width / 2, sz.height / 2))
    bg:addChild(black_bg)

    local url = 'spine/qianglingpai/qianglingpai'
    local name = 'qianglingpai'
    -- local spine = GlobalApi:createAniByName(name, url)
    local spine = GlobalApi:createSpineByName(name, url, 1)
    if spine ~= nil then
    	spine:registerSpineEventHandler( function ( event )
    			spine:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
    			recruitAudioId = nil
    			self:onFinish(black_bg, spine)
    		end, sp.EventType.ANIMATION_COMPLETE)

    	black_bg:addChild(spine)
    	spine:setLocalZOrder(999)
    	if self.recuitetype == 3 then
	    	spine:setAnimation(0, 'zhaomu2', false)
		else
			spine:setAnimation(0, 'zhaomu1', false)
		end

		recruitAudioId = AudioMgr.playEffect("media/effect/tavern_recruit.mp3", false)
	    spine:setPosition(cc.p(sz.width / 2, sz.height / 2))
    end

    black_bg:addClickEventListener(function (  )
    	self:onFinish(black_bg, spine)
    end)

	mask_bg:setCascadeOpacityEnabled(false)
	mask_bg:setOpacity(0)
end

function TavernAnimateUI:genCard(role)
	local node = cc.CSLoader:createNode('csb/taverncard.csb')




	local quality = role:getQuality()
	local frame = node:getChildByName('frame')
	frame:setLocalZOrder(98)
	-- frame:setRotation3D(cc.vec3(-45, 0, 0))
	frame:loadTexture(heroFrame[quality])
	local effectnode = frame:getChildByName('effect_node')
	local cardeffect = GlobalApi:createLittleLossyAniByName('ui_tavern_card_effect')
	cardeffect:setScale(2.2)
	cardeffect:setPosition(cc.p(3, 17))
	cardeffect:getAnimation():playWithIndex(0, -1, 1)
	cardeffect:getAnimation():setSpeedScale(0.8)
	effectnode:addChild(cardeffect, 1)


	local soldier_img = frame:getChildByName('soldier')
	soldier_img:loadTexture('uires/ui/common/soldier_'..role:getSoldierId()..'.png')
	soldier_img:ignoreContentAdaptWithSize(true)

	local layout = node:getChildByName('mask_white')
	layout:setLocalZOrder(99)

	local name = frame:getChildByName('name')
	name:setString(role:getName())
	name:setTextColor(cc.c4b(255, 247, 228, 255))
	name:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))

	local hero = frame:getChildByName('hero')
	hero:setLocalZOrder(999)
	local hid = role:getId()
	-- local aniName = role:getUrl() .. "_display"
	--print('name'..(role:getUrl() .. "_display"))
	local spine = GlobalApi:createLittleLossyAniByName(role:getUrl() .. "_display", nil, role:getChangeEquipState())
	--local effectIndex = 1
	-- repeat
	-- 	local aniEffect = spine:getBone(aniName .. "_effect" .. effectIndex)
	-- 	if aniEffect == nil then
	-- 		break
	-- 	end
	-- 	aniEffect:changeDisplayWithIndex(-1, true)
	-- 	aniEffect:setIgnoreMovementBoneData(true)
	-- 	effectIndex = effectIndex + 1
	-- until false
	local spineScale = 1.0
	if self.recuitetype ~= 3 then
		frame:setScale(1.5)
		if spine ~= nil then
			spine:setScale(0.7)
		end
	else
		if spine ~= nil then
			spine:setScale(0.7)
		end
	end
	
	if spine ~= nil then
		-- 刚开始就他妈是苦逼脸
		spine:getAnimation():play('idle', -1, 1)
		-- spine:setAnimation(0, 'idle', true)
		hero:addChild(spine)
		-- spine:setAnimation(0, 'shengli', true)
		local herosz = hero:getContentSize()
		local offsetY = GameData:getConfData('hero')[hid].uiOffsetY
		spine:setPosition(cc.p(herosz.width / 2, herosz.height / 2 + offsetY * spineScale))
	end

	-- card ++
	self.curCards = self.curCards + 1
	node:setName('card' .. self.curCards)
	table.insert(self.cardsPositions,
		self:getTenPosition(
			node:getContentSize(),
			self.mask_bg:getParent():getContentSize()
		)
	)

	return node, frame, spine, layout,cardeffect
end

function TavernAnimateUI:goAction()
	local ele = table.remove(self.awards)
	while (ele ~= nil and ele[1] ~= 'card') do
		ele = table.remove(self.awards)
	end
	if ele == nil then
		-- fly to the end position
		if self.recuitetype == 3 then
			for i = 1, 10 do
				-- print('i .............. ' .. i)
				self.mask_bg:getChildByName('card' .. i)
					:runAction(
						cc.Sequence:create(
							cc.MoveTo:create(0.2, self.cardsPositions[i]), 
							cc.CallFunc:create(function (  )
								-- actions finish
								self.againBtn:setVisible(true)
								self.godieBtn:setVisible(true)

								for k,v in pairs(self.cards) do
									-- print(k, v)
									v:setTouchEnabled(true)
								end
							end)))
			end
			self.cardsPositions = {}
			return
		end
		-- actions finish
		self.againBtn:setVisible(true)
		self.godieBtn:setVisible(true)

		for k,v in pairs(self.cards) do
			-- print(k, v)
			v:setTouchEnabled(true)
		end
		return
	end
	local role = ClassRoleObj.new(ele[2], ele[3])
	self.role = role
	if self.recuitetype ~= 3 then
		if self:isProcedure1(role) then
			self:singleUnderPuple(role)
		else
			self:singleOverPuple(role)
		end
		return
	else
		if self:isProcedure1(role) then
			self:tenUnderPuple(role)
		else
			self:tenOverPuple(role)
		end
	end
	return
end

function TavernAnimateUI:tenUnderPuple(role)
	local hnode, hFrame, heroSpine, layout,cardeffect = self:genCard(role)
	layout:setVisible(false)
	layout:setTouchEnabled(false)
	cardeffect:setVisible(false)

	hFrame:setTouchEnabled(false)
	hFrame:addClickEventListener(function (sender, eventType)
		ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
	end)

	table.insert(self.cards, hFrame)

	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()

	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	-- local pox, poy = self:getTenPosition(nodeSize, sz)
	AudioMgr.playEffect("media/effect/normal_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.MoveTo:create(0.2, positions[self.curCards]), cc.ScaleTo:create(0.2, 1), cc.RotateTo:create(0.2, 720)),
		cc.CallFunc:create(function()
				layout:setVisible(true)
				layout:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), 
					cc.CallFunc:create(function ()
							if heroSpine ~= nil then
								heroSpine:getAnimation():play('idle', -1, 1)
							end
							self:goAction()
						end)))
			end)))
end

function TavernAnimateUI:tenOverPuple(role)
	local hnode, hFrame, heroSpine, layout, cardeffect = self:genCard(role)
	layout:setVisible(false)
	layout:setTouchEnabled(false)
	cardeffect:setVisible(true)

	hFrame:setTouchEnabled(false)
	hFrame:addClickEventListener(function (sender, eventType)
		ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
	end)

	table.insert(self.cards, hFrame)

	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()
	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	-- local pox, poy = self:getTenPosition(nodeSize, sz)

	local bglight = ccui.ImageView:create()
	bglight:setScale(2)
	bglight:setTag(9527)
	bglight:loadTexture('uires/ui/tavern/light4.png')
	hnode:addChild(bglight, -1)
	bglight:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 10)))

	local bglight1 = ccui.ImageView:create()
	bglight1:setScale(1.7)
	bglight1:setRotation(math.random(120, 180))
	bglight1:setTag(9528)
	bglight1:loadTexture('uires/ui/tavern/light4.png')
	hnode:addChild(bglight1, -1)
	bglight1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -8)))

	bglight:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))
	bglight1:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))

	AudioMgr.playEffect("media/effect/special_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 2)), cc.RotateTo:create(0.4, 360)),
		cc.CallFunc:create(function()
				-- craete a new layout
				local backLayer = ccui.Layout:create()
				backLayer:setTouchEnabled(true)
				backLayer:setAnchorPoint(cc.p(0.5, 0.5))
				backLayer:setContentSize(sz)
				backLayer:setBackGroundColorType(LAYOUT_COLOR_SOLID)
				backLayer:setBackGroundColor(cc.c3b(5, 5, 5))
				backLayer:setBackGroundColorOpacity(200)
				backLayer:setTag(9119)
				hnode:addChild(backLayer, -10)

				hFrame:setTouchEnabled(true)
				if heroSpine ~= nil then
					role:playSound('sound')
					heroSpine:getAnimation():play('skill2', -1, 0)
					heroSpine:getAnimation():setMovementEventCallFunc(function ( armature, movementType, movementID )
						if movementType == 1 then
							heroSpine:getAnimation():play('idle', -1, 1)
							backLayer:addClickEventListener(function (sender, eventType)
									backLayer:setTouchEnabled(false)
									hFrame:setTouchEnabled(false)
									hnode:removeChildByTag(9527)
									hnode:removeChildByTag(9528)
									hnode:removeChildByTag(9119)
									role:stopSound('sound')
									hnode:runAction(cc.Sequence:create(cc.Spawn:create(
										cc.MoveTo:create(0.2, positions[self.curCards]), cc.ScaleTo:create(0.2, 1)),
										cc.CallFunc:create(function ()
												self:goAction()
											end)))
								end)
						end

						end)
				else
					backLayer:addClickEventListener(function (sender, eventType)
							backLayer:setTouchEnabled(false)
							hFrame:setTouchEnabled(false)
							hnode:removeChildByTag(9527)
							hnode:removeChildByTag(9528)
							hnode:removeChildByTag(9119)
							hnode:runAction(cc.Sequence:create(cc.Spawn:create(
								cc.MoveTo:create(0.2, positions[self.curCards]), cc.ScaleTo:create(0.2, 1)),
								-- cc.Shake:create(0.1, 10), 
								cc.CallFunc:create(function ()
										self:goAction()
									end)))
						end)
				end
			end)))
end

function TavernAnimateUI:singleUnderPuple(role)
	local hnode, hFrame, heroSpine, layout,cardeffect = self:genCard(role)
	layout:setVisible(false)
	cardeffect:setVisible(false)

	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()
	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setOpacity(50)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	AudioMgr.playEffect("media/effect/normal_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.FadeIn:create(0.4), cc.ScaleTo:create(0.4, 1), cc.RotateTo:create(0.4, 720)),
		cc.CallFunc:create(function()
				hFrame:setTouchEnabled(true)
				hFrame:addClickEventListener(function (sender, eventType)
					ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
				end)
				if heroSpine ~= nil then
					role:playSound('sound')
					heroSpine:getAnimation():play('skill2', -1, 0)
					heroSpine:getAnimation():setMovementEventCallFunc(function ( armature, movementType, movementID )
						if movementType == 1 then
							heroSpine:getAnimation():play('idle', -1, 1)
						end
					end)
				end
			end)))
end

function TavernAnimateUI:singleOverPuple(role)
	local hnode, hFrame, heroSpine, layout,cardeffect = self:genCard(role)
	layout:setVisible(false)
	cardeffect:setVisible(true)


	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()
	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setOpacity(50)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	local bglight = ccui.ImageView:create()
	bglight:setTag(9527)
	bglight:loadTexture('uires/ui/tavern/light4.png')

	local bglight1 = ccui.ImageView:create()
	bglight1:setRotation(math.random(120, 180))
	bglight1:setTag(9528)
	bglight1:loadTexture('uires/ui/tavern/light4.png')

	bglight:setScale(4)
	bglight1:setScale(3.4)

	hnode:addChild(bglight, -1)
	hnode:addChild(bglight1, -1)

	bglight:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 10)))
	bglight1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -8)))

	bglight:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))
	bglight1:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))

	AudioMgr.playEffect("media/effect/special_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.FadeIn:create(0.4), cc.ScaleTo:create(0.4, 1), cc.RotateTo:create(0.4, 720)),
		cc.CallFunc:create(function()
				hFrame:setTouchEnabled(true)
				hFrame:addClickEventListener(function (sender, eventType)
					ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
				end)
				if heroSpine ~= nil then
					role:playSound('sound')
					heroSpine:getAnimation():play('skill2', -1, 0)
					heroSpine:getAnimation():setMovementEventCallFunc(function ( armature, movementType, movementID )
						if movementType == 1 then
							heroSpine:getAnimation():play('idle', -1, 1)
						end
						end)
				end
			end)))
end

function TavernAnimateUI:isProcedure1(role)
	return role:getQuality() <= 4
end

function TavernAnimateUI:getTenPosition(nodeSize, sz)
	-- self.curCards = self.curCards + 1
	local avw = sz.width / 6
	local pox = 0
	local poy = 0
	local disy = 200
	if self.curCards <= 5 then
		pox = self.curCards * avw
		poy = sz.height / 2 + nodeSize.height / 2 + disy - 50
	else
		pox = (self.curCards - 5) * avw
		poy = sz.height / 2 - nodeSize.height / 2 - disy + 100
	end
	return cc.p(pox, poy)
end

function TavernAnimateUI:onFinish(black_bg, spine)
	local sz = black_bg:getContentSize()

	if recruitAudioId then
		AudioMgr.stopEffect(recruitAudioId)
		recruitAudioId = nil;
	end

	spine:runAction(cc.Sequence:create(
		cc.Spawn:create(cc.ScaleTo:create(0.4, 8), cc.FadeOut:create(0.4)),
		cc.DelayTime:create(1), 
    	cc.CallFunc:create(function()
    		-- designer said ' more and more actions...'
			-- light1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 90)))
			-- light2:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -30)))
			-- light3:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 40)))

      		black_bg:removeFromParent()
                	-- 烟花爆竹
			math.randomseed(os.clock()*10000)
			local num = math.random(3,4)
		    local black_bg = ccui.ImageView:create()
		    black_bg:loadTexture('uires/ui/common/bg_alpha2.png')
		    black_bg:setScale9Enabled(true)
		    black_bg:setContentSize(sz)
		    black_bg:setTouchEnabled(true)
		    black_bg:setPosition(cc.p(sz.width / 2, sz.height / 2))
			self.mask_bg:addChild(black_bg,2)
			for i=1,num do
				local totaldelaytime = 0
				local delaytime = math.random(1,3)
				totaldelaytime = totaldelaytime + 1/delaytime						
				self.mask_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(totaldelaytime),cc.CallFunc:create(
					function ()
						local winSize = cc.Director:getInstance():getWinSize()
						local scale = math.random(1,2)
						local list = math.random(1,5)
						local particle = cc.ParticleSystemQuad:create("particle/ui_tavern_fireworks_"..list..".plist")
						particle:setAutoRemoveOnFinish(true)
						local posx = math.random(0,winSize.width)
						local posy = math.random(200,winSize.height+200)
						particle:setPosition(cc.p(posx,posy))
						particle:setScale(scale)
						self.mask_bg:addChild(particle,1)
					end))))
			end
			self:goAction()
      	end)))
end

return TavernAnimateUI