from std.python import Python
from std.python.bindings import raise_python_exception
from std.sys import argv
from std.collections import Set
from std.os import setenv
from std.builtin import error

comptime HELP_TIME: String = '''a:Weekday, short version'
A:Weekday, full version'
w:Weekday as a number 0-6, 0 is Sunday
d:Day of month 01-31
b:Month name, short version
B:Month name, full version
m:Month as a number 01-12
y:Year, short version, without century
Y:Year, full version
H:Hour 00-23
I:Hour 00-12
p:AM/PM'
M:Minute 00-59
S:Second 00-59
f:Microsecond 000000-999999
z:UTC offset in the form ±HHMM[SS[.ffffff]] (empty string if the object is naive)
Z:Time zone name (empty string if the object is naive)
j:Day number of year 001-366
U:Week number of year, Sunday as the first day of week, 00-53
W:Week number of year, Monday as the first day of week, 00-53
c:Local version of date and time
C:Century
x:Local version of date
X:Local version of time
%:A % character
G:ISO 8601 year
u:ISO 8601 weekday (1-7)
V:ISO 8601 weeknumber (01-53)'''

comptime HELP_DATE: String = '''days:A day is converted to 24 hours
milliseconds={value}:A millisecond is converted to 1000 microseconds
minute={value}:A minute is converted to 60 seconds
hour={value}:An hour is converted into 3600 seconds
week={value}:A week is converted into 7 days'''

def main() raises:
    var valid: List[String] = ["days", "seconds", "microseconds", "milliseconds", "minutes", "hours", "weeks"]
    var date = Dict[String, Int]()
    var time = Set[String]()
    var args = argv()

    if args[1] == '--help' or args[1] == '-h':
        print('usage: get_time [-h] [--time {H,A,p,B,I,M,S,a,w,d,b,B,m,y,Y,f,z,Z,j,U,W,c,C,x,X,%,G,u,V} [{H,A,p,B,I,M,S,a,w,d,b,B,m,y,Y,f,z,Z,j,U,W,c,C,x,X,%,G,u,V} ...]]')
        print(HELP_DATE)
        print('usage: [--date UNIT=VALUE [UNIT=VALUE ...]]')
        print(HELP_TIME)
        return

    var dt = Python.import_module('datetime')
    var argparse = Python.import_module('argparse')
    var builtins = Python.import_module('builtins')
    var py_list = Python.list()
    var parser = argparse.ArgumentParser(prog='get_time')
    var time_mod = Python.import_module('time')
    var lt = time_mod.localtime()
    _ = parser.add_argument('--time', nargs="+",
        choices=['H','A','p','B','I','M','S','a','w','d','b','B','m','y','Y','f','z','Z','j','U','W','c','C','x','X','%','G','u','V'],
        default=Python.list(), help=HELP_TIME,
    )

    _ = parser.add_argument('--date', nargs='+', default=Python.list(), metavar="UNIT=VALUE", help=HELP_DATE)
    for i in args[1:]:
        py_list.append(builtins.str(i))

    var py_args = parser.parse_args(py_list)
    var time_output = List[String]()

    for i in py_args.time:
        if String(py=i) not in time:
            if i == 'Z':
                var timezone = lt.tm_zone
                time_output.append(String(py=timezone))
                continue
            if i == 'z':
                var timezone = lt.tm_gmtoff
                time_output.append(String(py=timezone))
                continue
            var datetime = dt.datetime.now()
            var get_dt = datetime.strftime("%" + Python.str(i))
            time_output.append(String(py=get_dt))
    print(' '.join(time_output))

    var count_check = 0
    for item in py_args.date:
        var string = String(py=item)
        var index = string.find('=')

        if index == -1:
            raise Error("--date expects unit=value, got: " + string)

        var unit = String(py=string[codepoint=:index])
        var value = atol(String(string[codepoint=index + 1:]))

        if not is_valid(unit, valid.copy()):
            raise Error("invalid unit '" + unit + "' in --date")

        date[unit] = value
        count_check += 1

    if count_check == 0:
        return

    var check = date.copy()
    for i in valid:
        var present = False
        for data in check.keys():
            if i == data:
                present = True
        if not present:
            date[i] = 0

    var delta = dt.timedelta(days=Python.int(date.get('days').value()), seconds=Python.int(date.get('seconds').value()), 
        microseconds=Python.int(date.get('microseconds').value()), milliseconds=Python.int(date.get('milliseconds').value()), 
        minutes=Python.int(date.get('minutes').value()), hours=Python.int(date.get('hours').value()), weeks=Python.int(date.get('weeks').value()))
    var now = dt.datetime.now()
    var output = now + delta
    print(output)

def flag() raises:
    raise Error("An exception has been logged")

def get_descriptions() -> Dict[String, String]:
    var output = Dict[String, String]()
    output['a'] = 'Weekday, short version\tWed'
    output['A'] = 'Weekday, full version\tWednesday'
    output['w'] = 'Weekday as a number 0-6, 0 is Sunday\t3' 
    output['d'] = 'Day of month 01-31\t31'
    output['b'] = 'Month name, short version\tDec' 	
    output['B'] = 'Month name, full version\tDecember' 	
    output['m'] = 'Month as a number 01-12\t12'
    output['y'] = 'Year, short version, without century\t18'
    output['Y'] = 'Year, full version\t2018'
    output['H'] = 'Hour 00-23\t17'
    output['I'] = 'Hour 00-12\t05'	
    output['p'] = 'AM/PM\tPM'
    output['M'] = 'Minute 00-59\t41' 	
    output['S'] = 'Second 00-59\t08'	
    output['f'] = 'Microsecond 000000-999999\t548513' 	
    output['z'] = 'UTC offset in the form ±HHMM[SS[.ffffff]] (empty string if the object is naive).\t+0100'	
    output['Z'] = 'Time zone name (empty string if the object is naive).\tCST'
    output['j'] = 'Day number of year 001-366\t365'
    output['U'] = 'Week number of year, Sunday as the first day of week, 00-53\t52'
    output['W'] = 'Week number of year, Monday as the first day of week, 00-53\t52'	
    output['c'] = 'Local version of date and time\tMon Dec 31 17:41:00 2018'
    output['C'] = 'Century\t20'
    output['x'] = 'Local version of date\t12/31/18'
    output['X'] = 'Local version of time\t17:41:00'	
    output['%'] = 'A % character\t%'
    output['G'] = 'ISO 8601 year\t2018' 	
    output['u'] = 'ISO 8601 weekday (1-7)\t1' 	
    output['V'] = 'ISO 8601 weeknumber (01-53)\t01'
    return output^

def get_timedelta() -> Dict[String, String]:
    var output = Dict[String, String]()
    output['days'] = 'A day is converted to 24 hours'
    output['milliseconds'] = 'A millisecond is converted to 1000 microseconds'
    output['minute'] = 'A minute is converted to 60 seconds'
    output['hour'] = 'An hour is converted into 3600 seconds'
    output['week'] = 'A week is converted into 7 days'
    return output^

def is_valid(unit: String, valid: List[String]) -> Bool:
    return True if unit in valid else False
