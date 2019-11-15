--[[
  @Description: 富文本专门解析用
  @Author: mrshi   参照 https://blog.csdn.net/x30465947/article/details/79637041
  @ 默认特殊颜色红色 正常颜色黑色
  @Date: 2019-11-12 15:54:04
 --]]
--专门解析用
local RichText = class("RichText", function ()
    return ccui.RichText:create()
end)
 
local NORMAL_TEXT = 0
 
local FONT_COMPONENT = 1     -- 不同颜色
local NEW_LINE_COMPONENT = 2 -- 换行<br>
local IMG_COMPONENT = 3 -- 图片<img></img>
local COMPONENT_CONFIG = { -- 模式串匹配
    [FONT_COMPONENT] = {
        -- ["all"] = "<%s-b.-><%s-font.->.-</%s-font%s-></%s-b->",
        ["all"] = "<%s-font.->.-</%s-font%s->",
        ["color"] = "color%s-=%s-'([^%s]*)'%s-",
        ["size"] = "size%s-=%s-(%d+)%s-",
        ["content"] = "<%s-font.->(.*)</%s-font%s->",
    },
 
    [NEW_LINE_COMPONENT] = {
        ["all"] = "<%s-[bB][rR]%s->",
 
    },
    -- <img src = \"ui_system/common/icon/normal/men_pai_gong_xian.png\" width=10 height=10 /> 
    [IMG_COMPONENT] = {
        ["all"] = "<%s-img%s-src%s-=.-/%s->",
        ["src"] = "src%s-=%s-[\"'](.-)[\"']%s-",
        ["width"] = "width%s-=%s-(%d+)%s-",
        ["height"] = "height%s-=%s-(%d+)%s-",
    },
}
-- param  
-- local param = "1、每日都可以锻炼 <font color='#9ced4d'> 3 </font>次<br>2、每日可领取声望×5000<br>3、锻炼次数<font color='#9ced4d'> 10 </font>次<br>4、物品购买次数<font color='#9ced4d'> 5 </font>次<br>5、人物鼓舞效果<font color='#9ced4d'> 2% </font><br>6、锻炼重置次数<font color='#9ced4d'> 1 </font>次<br>7、材料副本购买次数 <font color='#9ced4d'> 1 </font>次<br>8、<font color='#9ced4d'>“一键升你想说大号卢卡斯的阿是大号卢卡斯的机会阿是大号就啊你电话即可阿是大号简单生活阶神器功能”</font><br>"
function RichText:ctor( params )
        params = params or {}
        self.m_components = {}
        self.m_color      = params.color or cc.c3b(255, 0, 0) -- 特殊颜色
        self.m_size       = params.size or 26
end
 
function RichText:setText( _content )
    self.m_content    = _content
    self:update()
end
 
function RichText:update( ... )
    local PATTERN_CONFIG = COMPONENT_CONFIG
    self.m_components = {}
    local totalLen = string.len( self.m_content )
    local st = 0
    local en = 0
 
    for i = 1, #PATTERN_CONFIG, 1 do
        st = 0
        en = 0
 
        while true do
            st, en = string.find( self.m_content, PATTERN_CONFIG[i]["all"], st + 1 )
            if not st then
                break
            end
            local comp = {}
            comp.sIdx = st
            comp.eIdx = en
            comp.type = i
            comp.text = string.sub( self.m_content, comp.sIdx, comp.eIdx )
 
            table.insert( self.m_components, comp )
            st = en
        end
    end
 
    local function sortFunc( a, b )
        return a.sIdx < b.sIdx
    end
    table.sort( self.m_components, sortFunc )
 
    if #self.m_components <= 0 then
        local comp = {}
        comp.sIdx = 1
        comp.eidx = totalLen
        comp.type = NORMAL_TEXT
        comp.text = self.m_content
        table.insert( self.m_components, comp )
    else
        local offset = 1
        local newComponents = {}
 
        for i = 1, #self.m_components, 1 do
            local comp = self.m_components[ i ]
            table.insert( newComponents, comp )
 
            if comp.sIdx > offset then
                local newComp = {}
                newComp.sIdx = offset
                newComp.eIdx = comp.sIdx - 1
                newComp.type = NORMAL_TEXT
                newComp.text = string.sub( self.m_content, newComp.sIdx, newComp.eIdx )
 
                table.insert( newComponents, newComp )
            end
 
            offset = comp.eIdx + 1
        end
 
        if offset < totalLen then
            local newComp = {}
            newComp.sIdx = offset
            newComp.eIdx = totalLen
            newComp.type = NORMAL_TEXT
            newComp.text = string.sub( self.m_content, newComp.sIdx, newComp.eIdx )
 
            table.insert( newComponents, newComp )
        end
 
        self.m_components = newComponents
    end
 
    table.sort( self.m_components, sortFunc )
    -- dump(self.m_components)
    self:render()
 
    self:formatText()
end
 
function RichText:render()
    
    for i = 1, #self.m_components, 1 do
        local comp = self.m_components[i]
        local text = comp.text
 
        if comp.type == NORMAL_TEXT then
            self:handleNormalTextRender( text )
        elseif comp.type == FONT_COMPONENT then
            self:handleFontTextRender( text )
        elseif comp.type == NEW_LINE_COMPONENT then
            self:handleNewLineRender()
        elseif comp.type == IMG_COMPONENT then
            self:handleImgRender( text )
        end
    end
end
 
function RichText:handleNormalTextRender( _text )
    local color = cc.c3b(0, 0, 0)
    -- print("--一个无效参数---",color,_text,display.DEFAULT_TTF_FONT,self.m_size)
    local element = ccui.RichElementText:create(1, color, 255, _text or "", 'font/general.ttf', self.m_size)
    self:pushBackElement( element )
end
 
function RichText:handleFontTextRender( _text )
    local content = ""
    local color = self.m_color or cc.c3b(255, 0, 0)
    local size  = self.m_size or 26
 
    content = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["content"] )
    --如果xml里打算设定大小
    color = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["color"] ) or self.m_color
    size = string.match( _text, COMPONENT_CONFIG[ FONT_COMPONENT ]["size"] ) or self.m_size

    -- print("-- 另一个无效参数--",_text,color,content,size)
    local element = ccui.RichElementText:create(1, Game.util:c3b_parse(color), 255, content, 'font/general.ttf', size)
    self:pushBackElement( element )
end
 
function RichText:handleNewLineRender( ... )
    local color = cc.c3b(0,0,0)
    local element = ccui.RichElementNewLine:create(1, color, 255)
    self:pushBackElement( element )
end
 
function RichText:handleImgRender( _text )
    local src = string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "src" ] )
    local width = string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "width" ] )
    local height = string.match( _text, COMPONENT_CONFIG[ IMG_COMPONENT ][ "height" ] )
    -- print( ">>>> handleImgRender: " .. src .. ", w: " .. (width or "") .. ", h: " .. (height or "") )
    if src and width and height then
        local element = ccui.RichElementImage:create( 1, self.m_color, 255, src )
        self:pushBackElement( element )
    end
 end


return RichText