# Trying to reverse-engineer(?) this in ruby
# https://docs.python.org/3/library/argparse.html

class Argument
    @@name = ''
    @@short = ''
    @@type = ''
    @@desc = ''
    @@required = false

    def initialize(name, short, type, desc, required=false)
        @name = name
        @short = short
        @type = type
        @desc = desc
        @required = required
    end

    def get_name()
        return @name
    end

    def get_short()
        return @short
    end

    def get_type()
        return @type
    end

    def get_desc()
        return @desc
    end

    def is_required()
        return @required
    end
end

class ArgParser
    @@arguments = {}
    @@desc = ''

    def initialize()
        @arguments = {}
    end

    def add(name, short, type, desc, required=false)
        newarg = Argument.new(name, short, type, desc, required)
        @arguments[short] = newarg
    end

    def desc(desc)
        @desc = desc
    end
    
    def argparse()
        if ARGV[0] == '-h'
            print_help()
            return
        end
        res = {}
        for i in (0...ARGV.length()).step(2)
            short = ARGV[i][1]
            val = ARGV[i+1]
            arg = @arguments[short]
            if check_type(val, arg.get_type()) == false
                print_error(arg, val)
                return
            end
            res[short] = val
        end
        return res
    end

    def print_help()
        print('usage: ' + __FILE__ + ' [-h]')
        @arguments.each do |key, val|
            if val.is_required()
                print(' [-' + val.get_short() + '] ' + '(' + val.get_type().to_s() + ')')
            end
        end
        puts('')
        puts('')
        puts(@desc)
        puts('')
        @arguments.each do |key, val|
            puts('-' + val.get_short() + ' ' + val.get_name() + ' (' + val.get_type().to_s() + '): ' + val.get_desc())
        end
    end

    def print_error(arg, val)
        puts('error: argument ' + arg.get_short() + ': invalid ' + arg.get_type().to_s()  + ' value: ' + val.to_s())
    end

    # [x] int
    # [x] str
    # [ ] float
    # [x] bool
    def check_type(val, type) #str, int, float, bool
        if type == 'int'
            if (/^([-+]?\d+)$/).match(val) == nil
                return false
            end
            return true
        end

        if type == 'float'
            if (/^([-+]?\d+)?\.(\d+)$/).match(val) == nil
                return false
            end
            return true
        end

        if type == 'bool'
            if val != 'true' and val != 'false' and val != '0' and val != '1'
                return false
            end
            return true
        end

        if type == 'str'
            return true
        end
    end
end


# test
if __FILE__ == $0
    argparser = ArgParser.new()
    argparser.desc('Test description.')
    argparser.add('time', 'i', 'int', 'Set the video length', true)
    argparser.add('pause', 's', 'str', 'Set the pause time', false)
    argparser.add('acc', 'b', 'bool', 'Set acceleration rate', false)
    argparser.add('random', 'f', 'float', 'Set random var', false)
    args = argparser.argparse()
    puts(args)
end