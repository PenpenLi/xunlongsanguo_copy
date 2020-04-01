local ActivityThreeYuanBuyUI = class("ActivityThreeYuanBuyUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ActivityThreeYuanBuyUI:ctor(data)
	self.uiIndex = GAME_UI.UI_ACTIVITY_THREE_YUAN_BUY
    self.data = data
    UserData:getUserObj().activity.money_buy2 = self.data.money_buy2
end

function ActivityThreeYuanBuyUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img_1')
    local img = bgimg2:getChildByName('img')

    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            UserData:getUserObj().activity.money_buy2 = self.data.money_buy2
            MainSceneMgr:hideThreeYuanBuyUI()
        end
    end)
    self.closebtn = closebtn
    self.bgimg2 = bgimg2
    self:adaptUI(bgimg1, bgimg2)
    
    local name = bgimg2:getChildByName('name')
    name:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES16'))

    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(510, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES30'), 25, cc.c4b(254,227,134,255))
	re1:setStroke(cc.c4b(140,56,0,255),1)
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES23'), 25, COLOR_TYPE.RED)
	--re2:setStroke(cc.c4b(140,56,0,255),1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES24'), 25, cc.c4b(254,227,134,255))
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
    local buyBtn = self.bgimg2:getChildByName('buy_btn')
    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local rechageData = GameData:getConfData('recharge')
            if not rechageData[10] then
                return
            end
            if self.data.money_buy2.status == 0 then -- 充值
                self.buyBtn:setTouchEnabled(false)
                self.buyBtn:setBright(false)
                --self.closebtn:setTouchEnabled(false)
                local function callBack(obj)
                    if obj.code == 0 then
                        self.data.money_buy2.status = 1
                        self:refreshBtnStatus()
                        --self.closebtn:setTouchEnabled(true)
                    else
                        self.buyBtn:setTouchEnabled(true)
                        self.buyBtn:setBright(true)
                        --self.closebtn:setTouchEnabled(true)
                    end
                end
                RechargeMgr:specialRecharge(10,callBack)
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
    local _,time = ActivityMgr:getActivityTime("three_money_buy")
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
    local avOneYuanBuyConf = GameData:getConfData("avthreeyuanbuy")
    local name1 = ''
    local name2 = ''
    local num1 = 0
    local num2 = 0
    for i = 1,2 do
        local i = tonumber(i)
        local icon = self.bgimg2:getChildByName("icon_" .. i)

        local awardData = avOneYuanBuyConf[i].awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]
        if i == 1 then
            name1 = awards:getName()
            num1 = awards:getNum()
        else
            name2 = awards:getName()
            num2 = awards:getNum()
        end
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        local effect = GlobalApi:createLittleLossyAniByName('god_light')
        effect:setPosition(cc.p(94/2,94/2))
        effect:getAnimation():playWithIndex(0, -1, 1)
        effect:setName('god_light')
        effect:setScale(1.25)
        cell.awardBgImg:addChild(effect)

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

        local heroconf = GameData:getConfData('hero') 
        local cardData = heroconf[awards:getId()]

	    local re1 = xx.RichTextLabel:create(awards:getName(), 20, awards:getNameColor())
        re1:setFont('font/gamefont.ttf')

	    --local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES3'), 20, COLOR_TYPE.ORANGE)
        --re2:setFont('font/gamefont.ttf')

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
    for i = 1,2 do
        local getBtn = bgimg2:getChildByName('get_btn_' .. i)
        getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES9'))
        table.insert(self.getBtns,getBtn)
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.data.money_buy2.status == 1 then -- 领取
                    local function callBack()
                        local args = {
                            id = i
                        }
                        MessageMgr:sendPost('get_money_buy2_reward','activity',json.encode(args),function (jsonObj)
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
                                self.data.money_buy2.status = 2
                                self:refreshBtnStatus()
                            elseif jsonObj.code == 100 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES12'),COLOR_TYPE.RED)
                            end
                        end)
                    end
                    local name = name1
                    local num = num1
                    if i == 2 then
                        name = name2
                        num = num2
                    end
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES25'),name .. ' * ' .. num), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        callBack()
                    end)

                end
            end
        end)
    end
    
    local btn = HelpMgr:getBtn(27)
    btn:setScale(0.9)
    btn:setPosition(cc.p(50 ,422))
    bgimg2:addChild(btn)

    self:refreshBtnStatus()
end

-- sdk购买成功
function ActivityThreeYuanBuyUI:buySuccess()

end

-- sdk购买失败
function ActivityThreeYuanBuyUI:buyFail()
    
end

-- 刷新按钮状态
function ActivityThreeYuanBuyUI:refreshBtnStatus()
    for i = 1,2 do
        self.getBtns[i]:setVisible(false)
    end
    if self.data.money_buy2.status == 0 then -- 待充值
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(true)
        self.buyBtn:setTouchEnabled(true)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES14'))
    elseif self.data.money_buy2.status == 1 then -- 待领取
        self.buyBtn:setVisible(false)
        for i = 1,2 do
            self.getBtns[i]:setVisible(true)
        end
    elseif self.data.money_buy2.status == 2 then -- 已领取
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(false)
        self.buyBtn:setTouchEnabled(false)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES10'))
    end
end

return ActivityThreeYuanBuyUI