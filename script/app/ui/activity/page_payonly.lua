local PayOnly = class("PayOnly")
local ClassSellTips = require('script/app/ui/tips/selltips')
local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function PayOnly:init(msg)
    self.msg = msg
    self.rootBG = self.root:getChildByName("root")

    -- ��������
    UserData:getUserObj().activity.pay_only = msg.pay_only   

    UserData:getUserObj().payOnlyTag = 0
    if UserData:getUserObj().todayDoubleTag == 0 and UserData:getUserObj().luckyWheelTag == 0 and UserData:getUserObj().payOnlyTag == 0 then
        UserData:getUserObj().first_login = 0
    end

    -- �ۿ�ͼƬ
    self.imgDiscount = self.rootBG:getChildByName("img_discount")
    self.imgDiscount:setVisible(false)
    
    self:initData()
    self:initTop()
    self:initItems()

    self:updateMark()
end

function PayOnly:updateMark()
    if UserData:getUserObj():getSignByType('pay_only') then
		ActivityMgr:showMark("pay_only", true)
	else
		ActivityMgr:showMark("pay_only", false)
	end
end

function PayOnly:initData()
    self.payOnlyConf = GameData:getConfData('avpayonly')
    self.items = {} -- ���е���

end

function PayOnly:initTop()
    ActivityMgr:showLeftPayOnlyCue()
    ActivityMgr:showRightPayOnlyRemainTime()
end

function PayOnly:initItems()
    local sv = self.rootBG:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local cell = sv:getChildByName('frame')
    cell:setVisible(false)

    local num = #self.payOnlyConf
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * cell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end
    
    local offset = 0
    local tempHeight = cell:getContentSize().height
    for i = 1,num do
        local tempCell = cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0,allHeight - offset))
        sv:addChild(tempCell)

        local tempData = self.payOnlyConf[i]

        -- left
        local left = tempCell:getChildByName('left')
        local price = left:getChildByName('price')
        price:setString((DisplayData:getDisplayObjs(tempData.payAward))[1]:getNum())
        local des = left:getChildByName('des')
        des:setString(string.format(GlobalApi:getLocalStr('ACTIVE_PAY_ONLY_DES4'),tempData.require,tostring(tempData.cut)))

        local cash = left:getChildByName('cash')
        cash:loadTexture((DisplayData:getDisplayObjs(tempData.payAward))[1]:getIcon())
        cash:setTouchEnabled(true)
        cash:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI((DisplayData:getDisplayObjs(tempData.payAward))[1],false)
            end
        end)

        local taiziMask = tempCell:getChildByName('taizi_mask')
        taiziMask:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:getAward(i)
            end
        end)

        tempCell.tempData = tempData
        tempCell.leftGet = left:getChildByName('get')
        tempCell.leftGetState = left:getChildByName('get_state')
        tempCell.taiziMask = taiziMask
  

        tempCell.leftGetState:ignoreContentAdaptWithSize(true)

        tempCell.propCells = {}
        -- right
        for j = 1,3 do  -- ���3��
            local prop = tempCell:getChildByName('prop' .. j)
            if tempData['buy' .. j] ~= '0' then     -- ���ñ��������û����һ���ô����Ϊ'0'
                prop:setVisible(true)
                table.insert(tempCell.propCells,prop)

                local getBtn = prop:getChildByName('get_btn')
                getBtn:addTouchEventListener(function (sender, eventType)
		            if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then        
                        local awardData = DisplayData:getDisplayObjs(tempData['award' .. j])

                        local tab = {}
                        tab.icon = 'uires/ui/res/cash.png'
                        tab.num = UserData:getUserObj():getCash()   -- ӵ�е�Ԫ����
                        tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_CASH')
                        tab.id = 'cash'
                        tab.costNum = tempData['cutPrice' .. j]     -- ����
                        tab.confId = nil
                        tab.sellNum = 1     -- �����ʱ����û��
                                       
                        local buy = self.msg.pay_only.buy
                        local buyData = buy[tostring(i)]
                        local hasBuyCount = 0
                        if buyData then
                            for k,v in pairs(buyData) do
                                if tonumber(k) == j then
                                    hasBuyCount = tonumber(v)
                                    break
                                end
                            end
                        end

                        self:showTips(awardData[1],tab,nil,function(callback,num,cash)
                            if callback then
                                callback()
                            end
                            self:buyProp(i,j,num,cash)
                        end,nil,tempData['buy' .. j] - hasBuyCount)     -- ����ֻҪ���1����ڣ����������ʾ�������ƣ�����tab.sellNum��û������

                    end
                end)
                
                local priceLast = prop:getChildByName('price_last')
                priceLast:setString(tempData['oriPrice' .. j])
                local priceNow = prop:getChildByName('price_now')
                priceNow:setString(tempData['cutPrice' .. j])

                local disPlayData = DisplayData:getDisplayObjs(tempData['award' .. j])
                local awards = disPlayData[1]
                if awards then          
                    local icon = prop:getChildByName('icon')           
                    local awardCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
                    awardCell.awardBgImg:setPosition(cc.p(47,47))
                    awardCell.lvTx:setString('x'..awards:getNum())
                    local godId = awards:getGodId()
                    awards:setLightEffect(awardCell.awardBgImg)

                    -- ������ʾ
                    local imgDiscount = self.imgDiscount:clone()
                    awardCell.awardBgImg:addChild(imgDiscount)
                    imgDiscount:setVisible(true)
                    imgDiscount:getChildByName('price'):setString(string.format(GlobalApi:getLocalStr('ACTIVE_PAY_ONLY_DES6'),tostring(tempData.cut)))
                    imgDiscount:setPosition(cc.p(-14.88,36.45))

                end

                prop.remainCount = prop:getChildByName('remain_count')
                prop.cash = prop:getChildByName('cash')
                prop.priceLast = priceLast
                prop.priceNow = priceNow
                prop.hongxian = prop:getChildByName('hongxian')

                prop.getBtn = getBtn

            else
                prop:setVisible(false)
            end

        end

        table.insert(self.items, tempCell)
        self:updateItem(i)

    end
    innerContainer:setPositionY(size.height - allHeight)
end

function PayOnly:updateItem(id)
    local cell = self.items[id]
    local tempData = cell.tempData

    -- �������
    local nowCash = self.msg.pay_only.paid
    local costCash = tempData.require
    if nowCash >= costCash then
        local award = self.msg.pay_only.award    --����Ϊ{}
        local judge = false
        for k,v in pairs(award) do
            if tonumber(v) == id then
                judge = true
                break
            end
        end
        if judge == true then   -- �Ѿ���ȡ
            cell.leftGet:setVisible(false)
            cell.leftGetState:setVisible(true)
            cell.taiziMask:setVisible(false)
            cell.leftGetState:loadTexture(HASGETAWARD)
        else
            cell.leftGet:setVisible(true)
            cell.leftGetState:setVisible(false)
            cell.taiziMask:setVisible(true)
        end
    else
        cell.leftGet:setVisible(false)
        cell.leftGetState:setVisible(true)
        cell.taiziMask:setVisible(false)
        cell.leftGetState:loadTexture(NOTREATCH)
    end

    -- �����ұ�
    local buy = self.msg.pay_only.buy
    local propCells = cell.propCells
    local buyData = buy[tostring(id)]
    for i = 1,#propCells do
        local prop = propCells[i]

        local hasBuyCount = 0
        if buyData then
            for k,v in pairs(buyData) do
                if tonumber(k) == i then
                    hasBuyCount = tonumber(v)
                    break
                end
            end
        end
        if nowCash >= costCash then
            if tempData['buy' .. i] - hasBuyCount <= 0 then
                prop.getBtn:setTouchEnabled(false)
                ShaderMgr:setGrayForWidget(prop.getBtn)
                ShaderMgr:setGrayForWidget(prop.cash)
                ShaderMgr:setGrayForWidget(prop.hongxian)
                prop.priceLast:setColor(COLOR_TYPE.GRAY)
                prop.priceNow:setColor(COLOR_TYPE.GRAY)
            else
                prop.getBtn:setTouchEnabled(true)
                ShaderMgr:restoreWidgetDefaultShader(prop.getBtn)
                ShaderMgr:restoreWidgetDefaultShader(prop.cash)
                ShaderMgr:restoreWidgetDefaultShader(prop.hongxian)
                prop.priceLast:setColor(COLOR_TYPE.WHITE)
                prop.priceNow:setColor(COLOR_TYPE.WHITE)
            end
        else
            prop.getBtn:setTouchEnabled(false)
            ShaderMgr:setGrayForWidget(prop.getBtn)
            ShaderMgr:setGrayForWidget(prop.cash)
            ShaderMgr:setGrayForWidget(prop.hongxian)
            prop.priceLast:setColor(COLOR_TYPE.GRAY)
            prop.priceNow:setColor(COLOR_TYPE.GRAY)
        end

        prop.remainCount:setString(string.format(GlobalApi:getLocalStr('ACTIVE_PAY_ONLY_DES5'),tempData['buy' .. i] - hasBuyCount))
    end

end

function PayOnly:buyProp(id,index,num,cost)
    local function sendToServer()
		MessageMgr:sendPost('buy_pay_only','activity',json.encode({id = id,index = index,num = num or 1}),
		function(response)
			if(response.code ~= 0) then
				return
			end

            local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
				GlobalApi:showAwardsCommon(awards,nil,nil,true)
			end

			local costs = response.data.costs
			if costs then
				GlobalApi:parseAwardData(costs)
			end

            local buy = self.msg.pay_only.buy
            local buyData = buy[tostring(id)]
            local hasBuyCount = 0
            if buyData then
                local judgeBuy = false
                for k,v in pairs(buyData) do
                    if tonumber(k) == index then
                        hasBuyCount = tonumber(v) + num
                        judgeBuy = true
                        break
                    end
                end
                if judgeBuy == false then   -- �п�������û��
                    hasBuyCount = num
                end
                self.msg.pay_only.buy[tostring(id)][tostring(index)] = hasBuyCount
            else
                self.msg.pay_only.buy[tostring(id)] = {}
                self.msg.pay_only.buy[tostring(id)][tostring(index)] = num
            end

            self:updateItem(id)
		end)
	end
	UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
end

function PayOnly:getAward(id)
    MessageMgr:sendPost('get_pay_only_award','activity',json.encode({id = id}),
		function(response)
			if(response.code ~= 0) then
				return
			end
			local awards = response.data.awards
			if awards then
				GlobalApi:parseAwardData(awards)
				GlobalApi:showAwardsCommon(awards,nil,nil,true)
			end

            local award = self.msg.pay_only.award
            table.insert(award,id)

            self.msg.pay_only.award = award
            UserData:getUserObj().activity.pay_only.award = self.msg.pay_only.award

            self:updateItem(id)
			self:updateMark()
		end)
end

function PayOnly:showTips(award,tab,status,callback,sidebarList,num)
    local sellTipsUI = ClassSellTips.new(award,tab,status,callback,sidebarList,num)
    sellTipsUI:showUI()
end


return PayOnly