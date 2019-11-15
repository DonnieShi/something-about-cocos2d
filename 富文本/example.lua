--[[
  @Description: 说明面板
  @Author: mrshi
  @Date: 2019-11-12 16:09:57
 --]]
local configs = Game.configs
local template_rich_text = require("ui.common.common_richtext")

local meta = class("common_help_panel", require("ui.prototype"), function()
    return Game.helper:createCSLayer("interface/common/help_panel.csb", true)
end)

function meta:onCreate(text_src)
    self.text_src = text_src
    self.panel = self:getChildByName("panel")
    self.shadow = self:getChildByName("shadow")
    self.shadow:setTouchEnabled(true)
    self.shadow:setSwallowTouches(true)
    Game.helper:setTouchEnded(self.shadow,function()
        self:closePanel()
    end)

    self.bg = self.panel:getChildByName("bg")
    self.bg:setTouchEnabled(true)
    self.bg:setSwallowTouches(true)


    self.scroll = self.panel:getChildByName("scroll")
    self.scroll:setScrollBarEnabled(false)
    self:initScrollView()
end

function meta:initScrollView()
    local rich_text_node = template_rich_text.new()
    -- local test_text = "1、每日都可以锻炼 <font size =23 color='#9ced4d'> 3 </font>次<br>2、每日可领取声望×5000<br>3、锻炼次数<font color='#9ced4d'> 10 </font>次<br>4、物品购买次数<font color='#9ced4d'> 5 </font>次<br>5、人物鼓舞效果<font color='#9ced4d'> 2% </font><br>6、锻炼重置次数<font color='#9ced4d'> 1 </font>次<br>7、材料副本购买次数 <font color='#9ced4d'> 1 </font>次<br>8、<font color='#9ced4d'>“一键升你想说大号卢卡斯的阿是大号卢卡斯的机会阿是大号就啊你电话即可阿是大号简单生活阶神器功能”</font><br>"

    self.scroll:addChild(rich_text_node)    
    local scroll_size = self.scroll:getContentSize()
    rich_text_node:ignoreContentAdaptWithSize(false)
    rich_text_node:setAnchorPoint(cc.p(0,1))
    rich_text_node:setContentSize(scroll_size)

    rich_text_node:setText(self.text_src)
    local text_area_size = rich_text_node:getContentSize()
    rich_text_node:setPosition(cc.p(0,text_area_size.height > scroll_size.height and text_area_size.height or scroll_size.height))
    self.scroll:setInnerContainerSize(rich_text_node:getContentSize())
end


function meta:onEnter()
    self:play("enter", false, function ()
        self:play("normal")
    end)
end

function meta:exit()
    self:closePanel()
end






return meta