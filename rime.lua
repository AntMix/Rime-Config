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
        date_month = os.date('%m') -- 取月
        date_day = os.date('%d') -- 取日

        num_m1 = math.modf(date_month + 0)
        num_d1 = math.modf(date_day + 0)
        date = os.date('%Y年') .. tostring(num_m1) .. '月' .. tostring(num_d1) .. '日'

        -- 大写日期，类似二〇二〇年十一月二十六日
        data_year =
            data_year:gsub(
            '%d',
            {
                ['1'] = '一',
                ['2'] = '二',
                ['3'] = '三',
                ['4'] = '四',
                ['5'] = '五',
                ['6'] = '六',
                ['7'] = '七',
                ['8'] = '八',
                ['9'] = '九',
                ['0'] = '〇'
            }
        )
        data_year = data_year .. '年'

        date_month =
            date_month:gsub(
            '%d',
            {
                ['1'] = '一',
                ['2'] = '二',
                ['3'] = '三',
                ['4'] = '四',
                ['5'] = '五',
                ['6'] = '六',
                ['7'] = '七',
                ['8'] = '八',
                ['9'] = '九',
                ['0'] = ''
            }
        )
        date_month = date_month .. '月'
        if num_m1 == 10 then
            date_month = '十月'
        end
        if num_m1 == 11 then
            date_month = '十一月'
        end
        if num_m1 == 12 then
            date_month = '十二月'
        end

        date_day =
            date_day:gsub(
            '%d',
            {
                ['1'] = '一',
                ['2'] = '二',
                ['3'] = '三',
                ['4'] = '四',
                ['5'] = '五',
                ['6'] = '六',
                ['7'] = '七',
                ['8'] = '八',
                ['9'] = '九',
                ['0'] = ''
            }
        )
        date_day = date_day .. '日'
        if num_d1 > 9 then
            if num_d1 < 19 then
                date_day = '十' .. string.sub(date_day, 4, #date_day)
            end
        end
        if num_d1 > 19 then
            date_day = string.sub(date_day, 1, 3) .. '十' .. string.sub(date_day, 4, #date_day)
        end
        date_zh_cn = data_year .. date_month .. date_day

        -- 农历
        date_zh_td = toNyear(os.date('%Y'), os.date('%m'), os.date('%d'))
        date_zh_td = date_zh_td:gsub('年', '年')

        -- Candidate(type, start, end, text, comment)
        -- yield(Candidate('date', seg.start, seg._end, os.date('%Y年%m月%d日'), '')) -- 2020年03月31日 此格式基本不用
        yield(Candidate('date', seg.start, seg._end, date, '')) -- 2020年3月31日
        yield(Candidate('date', seg.start, seg._end, os.date('%Y-%m-%d'), '')) --2020-03-31
        yield(Candidate('date', seg.start, seg._end, date_zh_td, '')) -- 农历庚子(鼠)年三月初八
        yield(Candidate('date', seg.start, seg._end, date_zh_cn, '')) -- 二〇二〇年三月三十一日
    -- yield(Candidate('date', seg.start, seg._end, os.date('%Y%m%d'), '')) -- 20200331
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
        yield(Candidate('time', seg.start, seg._end, week, ' '))
    end
end

-- 时间(time) time
function time_translator(input, seg)
    -- Candidate(type, start, end, text, comment)
    if (input == 'time' or input == 'sj') then
        yield(Candidate('time', seg.start, seg._end, os.time(), ' ')) -- 时间戳
        yield(Candidate('time', seg.start, seg._end, os.date('%Y-%m-%d %H:%M:%S'), ''))
        yield(Candidate('time', seg.start, seg._end, os.date('%Y年%m月%d日 %H点%M分%S秒'), ''))
    end
end

-- 获取农历
function toNyear(year, mother, day)
    -- 天干名称
    local cTianGan = {
        '甲',
        '乙',
        '丙',
        '丁',
        '戊',
        '己',
        '庚',
        '辛',
        '壬',
        '癸'
    }
    -- 地支名称
    local cDiZhi = {
        '子',
        '丑',
        '寅',
        '卯',
        '辰',
        '巳',
        '午',
        '未',
        '申',
        '酉',
        '戌',
        '亥'
    }
    -- 属相名称
    local cShuXiang = {
        '鼠',
        '牛',
        '虎',
        '兔',
        '龙',
        '蛇',
        '马',
        '羊',
        '猴',
        '鸡',
        '狗',
        '猪'
    }
    -- 农历日期名
    local cDayName = {
        '*',
        '初一',
        '初二',
        '初三',
        '初四',
        '初五',
        '初六',
        '初七',
        '初八',
        '初九',
        '初十',
        '十一',
        '十二',
        '十三',
        '十四',
        '十五',
        '十六',
        '十七',
        '十八',
        '十九',
        '二十',
        '廿一',
        '廿二',
        '廿三',
        '廿四',
        '廿五',
        '廿六',
        '廿七',
        '廿八',
        '廿九',
        '三十'
    }
    -- 农历月份名
    local cMonName = {
        '*',
        '正',
        '二',
        '三',
        '四',
        '五',
        '六',
        '七',
        '八',
        '九',
        '十',
        '十一',
        '腊'
    }

    -- 公历每月前面的天数
    local wMonthAdd = {0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334}
    -- 农历数据
    local wNongliData = {
        2635,
        333387,
        1701,
        1748,
        267701,
        694,
        2391,
        133423,
        1175,
        396438,
        3402,
        3749,
        331177,
        1453,
        694,
        201326,
        2350,
        465197,
        3221,
        3402,
        400202,
        2901,
        1386,
        267611,
        605,
        2349,
        137515,
        2709,
        464533,
        1738,
        2901,
        330421,
        1242,
        2651,
        199255,
        1323,
        529706,
        3733,
        1706,
        398762,
        2741,
        1206,
        267438,
        2647,
        1318,
        204070,
        3477,
        461653,
        1386,
        2413,
        330077,
        1197,
        2637,
        268877,
        3365,
        531109,
        2900,
        2922,
        398042,
        2395,
        1179,
        267415,
        2635,
        661067,
        1701,
        1748,
        398772,
        2742,
        2391,
        330031,
        1175,
        1611,
        200010,
        3749,
        527717,
        1452,
        2742,
        332397,
        2350,
        3222,
        268949,
        3402,
        3493,
        133973,
        1386,
        464219,
        605,
        2349,
        334123,
        2709,
        2890,
        267946,
        2773,
        592565,
        1210,
        2651,
        395863,
        1323,
        2707,
        265877
    }

    local wCurYear, wCurMonth, wCurDay
    local nTheDate, nIsEnd, m, k, n, i, nBit
    local szNongli, szNongliDay, szShuXiang
    ---取当前公历年、月、日---
    wCurYear = tonumber(year)
    wCurMonth = tonumber(mother)
    wCurDay = tonumber(day)
    ---计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)---
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth] - 38
    if (((wCurYear % 4) == 0) and (wCurMonth > 2)) then
        nTheDate = nTheDate + 1
    end

    -- 计算农历天干、地支、月、日---
    nIsEnd = 0
    m = 0
    while nIsEnd ~= 1 do
        if wNongliData[m + 1] < 4095 then
            k = 11
        else
            k = 12
        end
        n = k
        while n >= 0 do
            -- 获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m + 1]
            for i = 1, n do
                nBit = math.floor(nBit / 2)
            end
            nBit = nBit % 2
            if nTheDate <= (29 + nBit) then
                nIsEnd = 1
                break
            end
            nTheDate = nTheDate - 29 - nBit
            n = n - 1
        end
        if nIsEnd ~= 0 then
            break
        end
        m = m + 1
    end

    wCurYear = 1921 + m
    wCurMonth = k - n + 1
    wCurDay = nTheDate
    if k == 12 then
        if wCurMonth == wNongliData[m + 1] / 65536 + 1 then
            wCurMonth = 1 - wCurMonth
        elseif wCurMonth > wNongliData[m + 1] / 65536 + 1 then
            wCurMonth = wCurMonth - 1
        end
    end
    wCurDay = math.floor(wCurDay)
    -- print('农历', wCurYear, wCurMonth, wCurDay)
    -- 生成农历天干、地支、属相 ==> wNongli--
    szShuXiang = cShuXiang[(((wCurYear - 4) % 60) % 12) + 1]
    szShuXiang = cShuXiang[(((wCurYear - 4) % 60) % 12) + 1]
    szNongli =
        '农历' ..
        cTianGan[(((wCurYear - 4) % 60) % 10) + 1] ..
            cDiZhi[(((wCurYear - 4) % 60) % 12) + 1] .. '(' .. szShuXiang .. ')年'
    -- szNongli,"%s(%s%s)年",szShuXiang,cTianGan[((wCurYear - 4) % 60) % 10],cDiZhi[((wCurYear - 4) % 60) % 12]);

    -- 生成农历月、日 ==> wNongliDay--*/
    if wCurMonth < 1 then
        szNongliDay = '闰' .. cMonName[(-1 * wCurMonth) + 1]
    else
        szNongliDay = cMonName[wCurMonth + 1]
    end

    szNongliDay = szNongliDay .. '月' .. cDayName[wCurDay + 1]
    return szNongli .. szNongliDay
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
