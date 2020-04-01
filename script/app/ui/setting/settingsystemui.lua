
local SettingSystemUI = class("SettingSystemUI", BaseUI)

function SettingSystemUI:ctor(obj,callback)
	self.uiIndex = GAME_UI.UI_SETTINGSYSTEM
	self.callback = callback
end

function SettingSystemUI:init()
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

	--title
	local titleBgImg = bg2:getChildByName('title_img')
	local infoTx = titleBgImg:getChildByName('tx')
	infoTx:setString(GlobalApi:getLocalStr("SETTING_SYSTEM_TITLE"))
	
	local panel = bg2:getChildByName('contentPanel')
	
	local musicText=panel:getChildByName('musicText')
	musicText:setString(GlobalApi:getLocalStr('SETTING_SYSTEM_MUSIC'))
	local soundText=panel:getChildByName('soundText')
	soundText:setString(GlobalApi:getLocalStr('SETTING_SYSTEM_SOUND'))
	local pushText=panel:getChildByName('pushText')
	pushText:setString(GlobalApi:getLocalStr('SETTING_SYSTEM_PUSHTEXT'))
	
	self.musicVal=cc.UserDefault:getInstance():getFloatForKey('musicValue', 1.0)
	self.soundVal=cc.UserDefault:getInstance():getFloatForKey('soundValue', 1.0)
	
	--music button
	self.musicBtn = panel:getChildByName('musicBtn')
	self.musicBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:SetMusicVal()
			AudioMgr.PlayAudio(11)
	    end
	end)
	if self.musicVal < 1.0 then
		self.musicBtn:loadTextureNormal("uires/ui/setting/guan.png")
	else
		self.musicBtn:loadTextureNormal("uires/ui/setting/kai.png")
	end
	
	--sound button
	self.soundBtn = panel:getChildByName('soundBtn')
	self.soundBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:SetSoundVal()
			AudioMgr.PlayAudio(11)
	    end
	end)
	if self.soundVal < 1.0 then
		self.soundBtn:loadTextureNormal("uires/ui/setting/guan.png")
	else
		self.soundBtn:loadTextureNormal("uires/ui/setting/kai.png")
	end
	--close button
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingSystem()
			AudioMgr.PlayAudio(11)
	    end
	end)		
	
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))

    local btns = {}

    local userBtn = panel:getChildByName('userBtn')
  	if Third:Get():isShowUserCenterBySDK() then
    	local tx = userBtn:getChildByName('tx')
    	tx:setString(GlobalApi:getLocalStr('SETTING_DESC_1'))
    	userBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	Third:Get():showUserCenterBySDK()
            end
        end)
        table.insert(btns, userBtn)
    else
    	userBtn:setVisible(false)
    end

    local serviceBtn = panel:getChildByName('serviceBtn')
    if Third:Get():getSDKPlatform() == "ddsg" and Third:Get():isShowServiceBySDK() then
    	local tx = serviceBtn:getChildByName('tx')
    	tx:setString(GlobalApi:getLocalStr('SETTING_DESC_3'))
    	serviceBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	Third:Get():showServiceBySDK()
            end
        end)
        table.insert(btns, serviceBtn)
    else
    	serviceBtn:setVisible(false)
    end

    local logoutBtn = panel:getChildByName('logoutBtn')
    if Third:Get():isShowLogoutBySDK() then
    	local tx = logoutBtn:getChildByName('tx')
    	tx:setString(GlobalApi:getLocalStr('SETTING_DESC_2'))
    	logoutBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
            	Third:Get():logoutBySDK()
            end
        end)
        table.insert(btns, logoutBtn)
    else
    	logoutBtn:setVisible(false)
    end

    local panelWidth = panel:getContentSize().width
    if #btns == 1 then
    	btns[1]:setPositionX(panelWidth/2)
    elseif #btns == 2 then
    	btns[1]:setPositionX(panelWidth/2 - 100)
    	btns[2]:setPositionX(panelWidth/2 + 100)
    end
end

function SettingSystemUI:ActionClose(call)
	local bg1 = self.root:getChildByName("bg1")
	local panel=ccui.Helper:seekWidgetByName(bg1,"bg2")
     panel:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
     panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
            if(call ~= nil) then
                return call()
            end
        end)))
end

function SettingSystemUI:SetMusicVal()
	if self.musicVal < 1.0 then
		self.musicVal=1.0
		cc.UserDefault:getInstance():setFloatForKey('musicValue', 1.0)
		self.musicBtn:loadTextureNormal("uires/ui/setting/kai.png")
	else
		self.musicVal=0.0
		cc.UserDefault:getInstance():setFloatForKey('musicValue', 0.0)
		self.musicBtn:loadTextureNormal("uires/ui/setting/guan.png")
	end
	print("SetMusicVal "..tonumber(self.musicVal))
	AudioMgr.setMusicVolume(self.musicVal)
	--cc.UserDefault:getInstance():flush()
end

function SettingSystemUI:SetSoundVal()
	if self.soundVal < 1.0 then
		self.soundVal=1.0
		cc.UserDefault:getInstance():setFloatForKey('soundValue', 1.0)
		self.soundBtn:loadTextureNormal("uires/ui/setting/kai.png")
	else
		self.soundVal=0.0
		cc.UserDefault:getInstance():setFloatForKey('soundValue', 0.0)
		self.soundBtn:loadTextureNormal("uires/ui/setting/guan.png")
	end
	print("SetSoundVal "..tonumber(self.soundVal))
	AudioMgr.setEffectsVolume(self.soundVal)
	--cc.UserDefault:getInstance():flush()
end

return SettingSystemUI