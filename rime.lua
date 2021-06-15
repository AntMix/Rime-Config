-- encoding: utf-8
-- Usage:
--  engine:
--    ...
--    translators:
--      ...
--      - lua_translator@date_translator
--      - lua_translator@time_translator
--      - lua_translator@execute

-- 日期 (date) 星期 (week)
function date_translator(input, seg)
    if (input == 'date') then
        data_year = os.date('%Y') -- 取年

        month = math.modf(os.date('%m') + 0)
        day = math.modf(os.date('%d')  + 0)
        date = os.date('%Y年') .. tostring(month) .. '月' .. tostring(day) .. '日'

        -- Candidate(type, start, end, text, comment)
        -- yield(Candidate('date', seg.start, seg._end, os.date('%Y年%m月%d日'), '')) -- 2020年03月31日 此格式基本不用
        yield(Candidate('date', seg.start, seg._end, os.date('%Y-%m-%d'), '')) --2020-03-31
        yield(Candidate('date', seg.start, seg._end, date, '')) -- 2020年3月31日
        yield(Candidate('date', seg.start, seg._end, os.date('%Y-%m-%d_%H%M%S'), '')) -- 2021-06-15_134321
    end
    if (input == 'week') then
        -- 星期
        local week_num = os.date('%w')
        local week = ''
        if week_num == '0' then
            week = '星期日'
        end
        if week_num == '1' then
            week = '星期一'
        end
        if week_num == '2' then
            week = '星期二'
        end
        if week_num == '3' then
            week = '星期三'
        end
        if week_num == '4' then
            week = '星期四'
        end
        if week_num == '5' then
            week = '星期五'
        end
        if week_num == '6' then
            week = '星期六'
        end
        yield(Candidate('week', seg.start, seg._end, week, ' '))
    end
    if (input == 'today') then
        yield(Candidate('today', seg.start, seg._end, os.date('%Y-%m-%d'), ''))
        yield(
            Candidate(
                'today',
                seg.start,
                seg._end,
                os.date('%Y-%m-%d') .. os.date(' %Y-%m-%d', os.time() + 86400),
                ''
            )
        )
    end
    if (input == 'yesterday') then
        yield(Candidate('yesterday', seg.start, seg._end, os.date('%Y-%m-%d', os.time() - 86400), ''))
        yield(
            Candidate(
                'yesterday',
                seg.start,
                seg._end,
                os.date('%Y-%m-%d', os.time() - 86400) .. os.date(' %Y-%m-%d'),
                ''
            )
        )
    end
end

-- 时间(time) time
function time_translator(input, seg)
    -- Candidate(type, start, end, text, comment)
    if (input == 'time' or input == 'sj') then
        yield(Candidate('time', seg.start, seg._end, os.time(), ' ')) -- 时间戳
        yield(Candidate('time', seg.start, seg._end, os.date('%H:%M:%S'), ''))
        yield(Candidate('time', seg.start, seg._end, os.date('%Y-%m-%d %H:%M:%S'), ''))
        yield(Candidate('time', seg.start, seg._end, os.date('%Y年%m月%d日 %H点%M分%S秒'), ''))
    end
end

-- 快捷运行软件/打开网站 (/cmd)
function execute(input, seg)
    if (input == '/cmd') then -- 打开命令行窗口
        strProgram = '"C:\\Windows\\system32\\cmd.exe"'
        strCmd = 'start "" ' .. strProgram
        os.execute(strCmd)
    end
    if (input == '/bd') then -- 打开百度
        strProgram = '"https://www.baidu.com/"'
        strCmd = 'start "" ' .. strProgram
        os.execute(strCmd)
    end
end

function mytranslator(input, seg)
    date_translator(input, seg)
    time_translator(input, seg)
    -- execute(input, seg)
end
