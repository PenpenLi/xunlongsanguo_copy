local ActivityOneYuanBuyUI = class("ActivityOneYuanBuyUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ActivityOneYuanBuyUI:ctor(data)
	self.uiIndex = GAME_UI.UI_ACTIVITY_ONE_YUAN_BUY
    self.data = data
    UserData:getUserObj().activity.money_buy = self.data.money_buy
end

function ActivityOneYuanBuyUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            UserData:getUserObj().activity.money_buy = self.data.money_buy
            MainSceneMgr:hideOneYuanBuyUI()
        end
    end)
    self.closebtn = closebtn
    self.bgimg2 = bgimg2
    self:adaptUI(bgimg1, bgimg2)
    
    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(510, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES26'), 25, cc.c4b(254,227,134,255))
	re1:setStroke(cc.c4b(140,56,0,255),1)
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES27'), 25, COLOR_TYPE.RED)
	--re2:setStroke(cc.c4b(140,56,0,255),1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES28'), 25, cc.c4b(254,227,134,255))
	re3:setStroke(cc.c4b(140,56,0,255),1)
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(340,277))
    self.bgimg2:addChild(richText)
    richText:format(true)

    --
    local _,time = ActivityMgr:getActivityTime("money_buy")
    if time > 0 then
        local time_desc = bgimg2:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES29'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 50,time_desc:getPositionY()))
        bgimg2:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600)))
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.WHITE,COLOR_TYPE.RED,CDTXTYPE.FRONT,str,COLOR_TYPE.WHITE,COLOR_TYPE.RED,22,nil,nil,nil)
    end

    -- 
    local buyBtn = self.bgimg2:getChildByName('buy_btn')
    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local rechageData = GameData:getConfData('recharge')
            if not rechageData[9] then
                return
            end
            if self.data.money_buy.status == 0 then -- 充值
                self.buyBtn:setTouchEnabled(false)
                self.buyBtn:setBright(false)
                --self.closebtn:setTouchEnabled(false)
                local function callBack(obj)
                    if obj.code == 0 then
                        self.data.money_buy.status = 1
                        self:refreshBtnStatus()
                        --self.closebtn:setTouchEnabled(true)
                    else
                        self.buyBtn:setTouchEnabled(true)
                        self.buyBtn:setBright(true)
                        --self.closebtn:setTouchEnabled(true)
                    end
                end
                RechargeMgr:specialRecharge(9,callBack)
                self.buyBtn:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
					self.buyBtn:setTouchEnabled(true)
                    self.buyBtn:setBright(true)
                    --self.closebtn:setTouchEnabled(true)
                end)))
            end
        end
    end)
    self.buyBtn = buyBtn
    self.buyBtnTx = buyBtn:getChildByName('tx')

    -- 
    local avOneYuanBuyConf = GameData:getConfData("avoneyuanbuy")
    local num1 = 0
    local num2 = 0

    local awardData = avOneYuanBuyConf[1].awards
    local disPlayData = DisplayData:getDisplayObjs(awardData)

    for i = 1,2 do
        local i = tonumber(i)
        local icon = self.bgimg2:getChildByName("icon_" .. i)

        --local awardData = avOneYuanBuyConf[i].awards
        --local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[i]
        if i == 1 then
            num1 = awards:getNum()
        else
            num2 = awards:getNum()
        end

        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        cell.awardBgImg:setPosition(cc.p(94/2, 94/2))
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        -- 名字
        local richTextName = xx.RichText:create()
	    richTextName:setContentSize(cc.size(510, 40))

        local color = COLOR_TYPE.RED
        if i == 1 then
            color = COLOR_TYPE.BLUE
        elseif i == 2 then
            color = COLOR_TYPE.GREEN
        elseif i == 3 then
            color = COLOR_TYPE.RED
        else
            color = COLOR_TYPE.YELLOW
        end

	    --local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES' .. i + 3), 24, color)
        --re1:setFont('font/gamefont.ttf')

	    local re1 = xx.RichTextLabel:create(awards:getName(), 20, COLOR_TYPE.ORANGE)
        re1:setFont('font/gamefont.ttf')

	    richTextName:addElement(re1)
	    --richTextName:addElement(re2)

        richTextName:setAlignment('middle')
        richTextName:setVerticalAlignment('middle')

	    richTextName:setAnchorPoint(cc.p(0.5,0.5))
	    richTextName:setPosition(cc.p(icon:getContentSize().width/2,-22))
        icon:addChild(richTextName)
        richTextName:format(true)
    end

    self.getBtns = {}
    for i = 1,1 do
        local getBtn = bgimg2:getChildByName('get_btn_' .. i)
        getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES9'))
        table.insert(self.getBtns,getBtn)
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.data.money_buy.status == 1 then -- 领取
                    local function callBack()
                        local args = {
                            id = i
                        }
                        MessageMgr:sendPost('get_money_buy_reward','activity',json.encode(args),function (jsonObj)
                        print(json.encode(jsonObj))
                            if jsonObj.code == 0 then
                                local awards = jsonObj.data.awards
                                if awards then
                                    GlobalApi:parseAwardData(awards)
                                    GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                                end
                                local costs = jsonObj.data.costs
                                if costs then
                                    GlobalApi:parseAwardData(costs)
                                end
                                self.data.money_buy.status = 2
                                self:refreshBtnStatus()
                            elseif jsonObj.code == 100 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES12'),COLOR_TYPE.RED)
                            end
                        end)
                    end

                    --promptmgr:showMessageBox(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES11'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        callBack()
                    --end)

                end
            end
        end)
    end
    
    --
    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(600, 40))

	local re1 = xx.RichTextImage:create('uires/icon/user/cash.png')
    re1:setScale(0.7)

	local re2 = xx.RichTextLabel:create(' ' .. num1 .. ' +  ', 26, COLOR_TYPE.WHITE)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextImage:create('uires/icon/user/food.png')
    re3:setScale(0.7)

    local re4 = xx.RichTextLabel:create(num2, 26, COLOR_TYPE.WHITE)
    re2:setFont('font/gamefont.ttf')

	richText2:addElement(re1)
	richText2:addElement(re2)
    richText2:addElement(re3)
    richText2:addElement(re4)

    richText2:setAlignment('left')
    richText2:setVerticalAlignment('middle')

	richText2:setAnchorPoint(cc.p(0,0.5))
	richText2:setPosition(cc.p(565 - 83,352))
    self.bgimg2:addChild(richText2)
    richText2:format(true)

    local btn = HelpMgr:getBtn(25)
    btn:setScale(0.9)
    btn:setPosition(cc.p(50 ,422))
    bgimg2:addChild(btn)

    self:refreshBtnStatus()
    cc.UserDefault:getInstance():setStringForKey(UserData:getUserObj():getUid() .. 'money_buy_time',Time.beginningOfToday())
end

-- sdk购买成功
function ActivityOneYuanBuyUI:buySuccess()

end

-- sdk购买失败
function ActivityOneYuanBuyUI:buyFail()
    
end

-- 刷新按钮状态
function ActivityOneYuanBuyUI:refreshBtnStatus()
    for i = 1,1 do
        self.getBtns[i]:setVisible(false)
    end
    if self.data.money_buy.status == 0 then -- 待充值
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(true)
        self.buyBtn:setTouchEnabled(true)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES8'))
    elseif self.data.money_buy.status == 1 then -- 待领取
        self.buyBtn:setVisible(false)
        for i = 1,1 do
            self.getBtns[i]:setVisible(true)
        end
    elseif self.data.money_buy.status == 2 then -- 已领取
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(false)
        self.buyBtn:setTouchEnabled(false)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES10'))
    end
end

return ActivityOneYuanBuyUI