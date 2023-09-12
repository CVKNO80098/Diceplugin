msg_order = {}

local version=0.1
local setOrderSET="选词库"
local setOrderDraw="抽单词"
local showLearningList = ".showLearningList"
local helpDoc = "词库！".."版本："..version.."\n帮助：\n    选词库 <对应词库名称>\n当前收录词库：\n    初中、高中、英语四六级、SAT、托福、考研\n示例：选词库 英语四级"

local json = require("json")

global_path = getDiceDir().."/plugin/EnglishTr/"

local ciku1 = global_path .. "1chuzhong.json"
local ciku2 = global_path .. "2gaozhong.json"
local ciku3 = global_path .. "CET4.json"
local ciku4 = global_path .. "CET6.json"
local ciku5 = global_path .. "SAT.json"
local ciku6 = global_path .. "tuofu.json"
local ciku7 = global_path .. "yan.json"


--基本函数：提取信息
function extractInfo(input, trigger)
    local resultList = {}  -- 用于存储提取的结果

    -- 过滤触发机制和提取主要信息
    local mainInfo = string.match(input, "^" .. trigger .. " (.*)$")
    if mainInfo then
        -- 触发机制后面有值，继续处理
        for value in string.gmatch(mainInfo, "%S+") do
            table.insert(resultList, value)
        end
    else
        -- 触发机制后面没有值，返回特定结果
        return nil  -- 或者返回其他您认为合适的结果
    end
    return resultList  -- 返回汇总的结果表
end
--基础函数：查询字符串
function ContainsValue(list, target)
    if (list==nil) then 
        return false
    end
    for _, value in ipairs(list) do
        if value == target then
            return true  -- 找到了，返回 true
        end
    end
    return false  -- 没找到，返回 false
end
--主函数：返回信息
msg_order[setOrderDraw] = "Head_GetThesaurus"
function Head_GetThesaurus()
    local userConf = getUserConf(msg.fromQQ, "EnglishLearnThesaurus",0) 
    if (userConf~=0) then
        return GetThesaurus(userConf)   
    else
        return helpDoc 
    end
end
function GetThesaurus(Choice)

    if Choice==1 then
        file = io.open(ciku1, "r")
    elseif Choice==2 then
        file = io.open(ciku2, "r")
    elseif Choice==3 then
        file = io.open(ciku3, "r")
    elseif Choice==4 then
        file = io.open(ciku4, "r")
    elseif Choice==5 then
        file = io.open(ciku5, "r")
    elseif Choice==6 then
        file = io.open(ciku6, "r")
    elseif Choice==7 then
        file = io.open(ciku7, "r")
    else
        return "您的程序出现问题，请检查"
    end
    local output = "" -- 用于存储生成的文本

    if file then
        local json_data = file:read("*all")
        file:close()

        local data = json.decode(json_data)

        -- 选择第一个数据条目
        local key = data[ranint(0,#data)]

        -- 输出单词
        output = output .. key.word .. ":" .. "\n" 
        -- 输出翻译
        for _, value in ipairs(key.translations) do
            if value.type then
                output = output .. value.type .. ":" ..  value.translation .. "\n"
            else
                output = output .. value.translation .. "\n"
            end
        end

        -- 输出短语（如果存在）
        if key.phrases then
            output = output .. "短语：" .. "\n"
            for _, phrase in ipairs(key.phrases) do
                output = output .. "    " .. phrase.phrase .. ":" ..  phrase.translation .. "\n"
            end
        end
    else
        output = "无法打开文件"
    end
    return output -- 返回生成的文本
end

msg_order[setOrderSET] = "SetThesaurus"
function CheckTextRule(MsgList)
	if (ContainsValue(MsgList,"初中")==true or ContainsValue(MsgList,"初中词库")==true or ContainsValue(MsgList, "初中单词")==true) then
		local result = 1
		return result
    elseif (ContainsValue(MsgList,"高中词库")==true or ContainsValue(MsgList,"高中")==true or ContainsValue(MsgList,"高中单词")==true) then
		local result = 2
		return result
    elseif (ContainsValue(MsgList,"CET4")==true or ContainsValue(MsgList,"英语四级")==true or ContainsValue(MsgList,"英语四级词汇")==true or ContainsValue(MsgList,"英语四级词库")==true) then
		local result = 3
		return result
    elseif (ContainsValue(MsgList,"CET6")==true or ContainsValue(MsgList,"英语六级")==true or ContainsValue(MsgList,"英语六级词汇")==true or ContainsValue(MsgList,"英语六级级词库")==true) then
		local result = 4
		return result
    elseif (ContainsValue(MsgList,"SAT")==true) then
        local result = 5
        return result
    elseif (ContainsValue(MsgList,"托福")==true or ContainsValue(MsgList,"托福词汇")==true or ContainsValue(MsgList,"托福词库")==true) then
		local result = 6
		return result
    elseif (ContainsValue(MsgList,"考研")==true or ContainsValue(MsgList,"考研词汇")==true or ContainsValue(MsgList,"考研词库")==true) then
		local result = 7
		return result
    else
        return false
    end
end
msg_order[setOrderSET] = "SetThesaurus"
function SetThesaurus()
    local resultList = extractInfo(msg.fromMsg, setOrderSET)
    local resultCat = CheckTextRule(resultList)
    if (resultCat~=false)then
        setUserConf(msg.fromQQ, "EnglishLearnThesaurus", resultCat)
        return "成功！您选择啦" .. resultCat
    else
        return "请参考下面的Help输入嗷\n" .. helpDoc
    end
end
msg_order[showLearningList] = "ShowLearningList"
function ShowLearningList()
    local list = getUserConf(msg.fromQQ, "EnglishLearnThesaurus",0)
    if (list == 0) then
        return "还没有学习嗷...\n" .. helpDoc
    else
        return list
    end
end