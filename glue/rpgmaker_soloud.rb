module DL
	# The mutual exclusion (Mutex) semaphore for the DL module
  SEM = Mutex.new # :nodoc:

  def set_callback_internal(proc_entry, addr_entry, argc, ty, abi = nil, &cbp)
    if( argc < 0 )
      raise(ArgumentError, "arity should not be less than 0.")
    end
    addr = nil

    if DL.fiddle?
      abi ||= Fiddle::Function::DEFAULT
      closure = Fiddle::Closure::BlockCaller.new(ty, [TYPE_VOIDP] * argc, abi, &cbp)
      proc_entry[closure.to_i] = closure
      addr = closure.to_i
    else
      SEM.synchronize{
        ary = proc_entry[ty]
        (0...MAX_CALLBACK).each{|n|
          idx = (n * DLSTACK_SIZE) + argc
          if( ary[idx].nil? )
            ary[idx] = cbp
            addr = addr_entry[ty][idx]
            break
          end
        }
      }
    end

    addr
  end

  def set_cdecl_callback(ty, argc, &cbp)
    set_callback_internal(CdeclCallbackProcs, CdeclCallbackAddrs, argc, ty, &cbp)
  end

  def set_stdcall_callback(ty, argc, &cbp)
    if DL.fiddle?
      set_callback_internal(StdcallCallbackProcs, StdcallCallbackAddrs, argc, ty, Fiddle::Function::STDCALL, &cbp)
    else
      set_callback_internal(StdcallCallbackProcs, StdcallCallbackAddrs, argc, ty, &cbp)
    end
  end

  def remove_callback_internal(proc_entry, addr_entry, addr, ctype = nil)    
    index = nil
    if( ctype )
      addr_entry[ctype].each_with_index{|xaddr, idx|
        if( xaddr == addr )
          index = idx
        end
      }
    else
      addr_entry.each{|ty,entry|
        entry.each_with_index{|xaddr, idx|
          if( xaddr == addr )
            index = idx
          end
        }
      }
    end
    if( index and proc_entry[ctype][index] )
      proc_entry[ctype][index] = nil
      return true
    else
      return false
    end
  end

  def remove_cdecl_callback(addr, ctype = nil)
    remove_callback_internal(CdeclCallbackProcs, CdeclCallbackAddrs, addr, ctype)
  end

  def remove_stdcall_callback(addr, ctype = nil)
    remove_callback_internal(StdcallCallbackProcs, StdcallCallbackAddrs, addr, ctype)
  end

  alias set_callback set_cdecl_callback
  alias remove_callback remove_cdecl_callback
end


module DL
  class Stack
    def self.[](*types)
      new(types)
    end

    def initialize(types)
      parse_types(types)
    end

    def size()
      @size
    end

    def types()
      @types
    end

    def pack(ary)
      case SIZEOF_VOIDP
      when SIZEOF_LONG
        ary.pack(@template).unpack('l!*')
      when SIZEOF_LONG_LONG
        ary.pack(@template).unpack('q*')
      else
        raise(RuntimeError, "sizeof(void*)?")
      end
    end

    def unpack(ary)
      case SIZEOF_VOIDP
      when SIZEOF_LONG
        ary.pack('l!*').unpack(@template)
      when SIZEOF_LONG_LONG
        ary.pack('q*').unpack(@template)
      else
        raise(RuntimeError, "sizeof(void*)?")
      end
    end

    private

    def align(addr, align)
      d = addr % align
      if( d == 0 )
        addr
      else
        addr + (align - d)
      end
    end

    ALIGN_MAP = {
      TYPE_VOIDP => ALIGN_VOIDP,
      TYPE_CHAR  => ALIGN_VOIDP,
      TYPE_SHORT => ALIGN_VOIDP,
      TYPE_INT   => ALIGN_VOIDP,
      TYPE_LONG  => ALIGN_VOIDP,
      TYPE_FLOAT => ALIGN_FLOAT,
      TYPE_DOUBLE => ALIGN_DOUBLE,
    }

    PACK_MAP = {
      TYPE_VOIDP => ((SIZEOF_VOIDP == SIZEOF_LONG_LONG)? "q" : "l!"),
      TYPE_CHAR  => "c",
      TYPE_SHORT => "s!",
      TYPE_INT   => "i!",
      TYPE_LONG  => "l!",
      TYPE_FLOAT => "f",
      TYPE_DOUBLE => "d",
    }

    SIZE_MAP = {
      TYPE_VOIDP => SIZEOF_VOIDP,
      TYPE_CHAR  => SIZEOF_CHAR,
      TYPE_SHORT => SIZEOF_SHORT,
      TYPE_INT   => SIZEOF_INT,
      TYPE_LONG  => SIZEOF_LONG,
      TYPE_FLOAT => SIZEOF_FLOAT,
      TYPE_DOUBLE => SIZEOF_DOUBLE,
    }
    if defined?(TYPE_LONG_LONG)
      ALIGN_MAP[TYPE_LONG_LONG] = ALIGN_LONG_LONG
      PACK_MAP[TYPE_LONG_LONG] = "q"
      SIZE_MAP[TYPE_LONG_LONG] = SIZEOF_LONG_LONG
    end

    def parse_types(types)
      @types = types
      @template = ""
      addr      = 0
      types.each{|t|
        addr = add_padding(addr, ALIGN_MAP[t])
        @template << PACK_MAP[t]
        addr += SIZE_MAP[t]
      }
      addr = add_padding(addr, ALIGN_MAP[SIZEOF_VOIDP])
      if( addr % SIZEOF_VOIDP == 0 )
        @size = addr / SIZEOF_VOIDP
      else
        @size = (addr / SIZEOF_VOIDP) + 1
      end
    end

    def add_padding(addr, align)
      orig_addr = addr
      addr = align(orig_addr, align)
      d = addr - orig_addr
      if( d > 0 )
        @template << "x#{d}"
      end
      addr
    end
  end
end

module DL
  module PackInfo
    ALIGN_MAP = {
      TYPE_VOIDP => ALIGN_VOIDP,
      TYPE_CHAR  => ALIGN_CHAR,
      TYPE_SHORT => ALIGN_SHORT,
      TYPE_INT   => ALIGN_INT,
      TYPE_LONG  => ALIGN_LONG,
      TYPE_FLOAT => ALIGN_FLOAT,
      TYPE_DOUBLE => ALIGN_DOUBLE,
      -TYPE_CHAR  => ALIGN_CHAR,
      -TYPE_SHORT => ALIGN_SHORT,
      -TYPE_INT   => ALIGN_INT,
      -TYPE_LONG  => ALIGN_LONG,
    }

    PACK_MAP = {
      TYPE_VOIDP => ((SIZEOF_VOIDP == SIZEOF_LONG_LONG) ? "q" : "l!"),
      TYPE_CHAR  => "c",
      TYPE_SHORT => "s!",
      TYPE_INT   => "i!",
      TYPE_LONG  => "l!",
      TYPE_FLOAT => "f",
      TYPE_DOUBLE => "d",
      -TYPE_CHAR  => "c",
      -TYPE_SHORT => "s!",
      -TYPE_INT   => "i!",
      -TYPE_LONG  => "l!",
    }

    SIZE_MAP = {
      TYPE_VOIDP => SIZEOF_VOIDP,
      TYPE_CHAR  => SIZEOF_CHAR,
      TYPE_SHORT => SIZEOF_SHORT,
      TYPE_INT   => SIZEOF_INT,
      TYPE_LONG  => SIZEOF_LONG,
      TYPE_FLOAT => SIZEOF_FLOAT,
      TYPE_DOUBLE => SIZEOF_DOUBLE,
      -TYPE_CHAR  => SIZEOF_CHAR,
      -TYPE_SHORT => SIZEOF_SHORT,
      -TYPE_INT   => SIZEOF_INT,
      -TYPE_LONG  => SIZEOF_LONG,
    }
    if defined?(TYPE_LONG_LONG)
      ALIGN_MAP[TYPE_LONG_LONG] = ALIGN_MAP[-TYPE_LONG_LONG] = ALIGN_LONG_LONG
      PACK_MAP[TYPE_LONG_LONG] = PACK_MAP[-TYPE_LONG_LONG] = "q"
      SIZE_MAP[TYPE_LONG_LONG] = SIZE_MAP[-TYPE_LONG_LONG] = SIZEOF_LONG_LONG
    end

    def align(addr, align)
      d = addr % align
      if( d == 0 )
        addr
      else
        addr + (align - d)
      end
    end
    module_function :align
  end

  class Packer
    include PackInfo

    def self.[](*types)
      new(types)
    end

    def initialize(types)
      parse_types(types)
    end

    def size()
      @size
    end

    def pack(ary)
      case SIZEOF_VOIDP
      when SIZEOF_LONG
        ary.pack(@template)
      when SIZEOF_LONG_LONG
        ary.pack(@template)
      else
        raise(RuntimeError, "sizeof(void*)?")
      end
    end

    def unpack(ary)
      case SIZEOF_VOIDP
      when SIZEOF_LONG
        ary.join().unpack(@template)
      when SIZEOF_LONG_LONG
        ary.join().unpack(@template)
      else
        raise(RuntimeError, "sizeof(void*)?")
      end
    end

    private

    def parse_types(types)
      @template = ""
      addr     = 0
      types.each{|t|
        orig_addr = addr
        if( t.is_a?(Array) )
          addr = align(orig_addr, ALIGN_MAP[TYPE_VOIDP])
        else
          addr = align(orig_addr, ALIGN_MAP[t])
        end
        d = addr - orig_addr
        if( d > 0 )
          @template << "x#{d}"
        end
        if( t.is_a?(Array) )
          @template << (PACK_MAP[t[0]] * t[1])
          addr += (SIZE_MAP[t[0]] * t[1])
        else
          @template << PACK_MAP[t]
          addr += SIZE_MAP[t]
        end
      }
      addr = align(addr, ALIGN_MAP[TYPE_VOIDP])
      @size = addr
    end
  end
end


module DL
  module ValueUtil
    def unsigned_value(val, ty)
      case ty.abs
      when TYPE_CHAR
        [val].pack("c").unpack("C")[0]
      when TYPE_SHORT
        [val].pack("s!").unpack("S!")[0]
      when TYPE_INT
        [val].pack("i!").unpack("I!")[0]
      when TYPE_LONG
        [val].pack("l!").unpack("L!")[0]
      when TYPE_LONG_LONG
        [val].pack("q").unpack("Q")[0]
      else
        val
      end
    end

    def signed_value(val, ty)
      case ty.abs
      when TYPE_CHAR
        [val].pack("C").unpack("c")[0]
      when TYPE_SHORT
        [val].pack("S!").unpack("s!")[0]
      when TYPE_INT
        [val].pack("I!").unpack("i!")[0]
      when TYPE_LONG
        [val].pack("L!").unpack("l!")[0]
      when TYPE_LONG_LONG
        [val].pack("Q").unpack("q")[0]
      else
        val
      end
    end

    def wrap_args(args, tys, funcs, &block)
      result = []
      tys ||= []
      args.each_with_index{|arg, idx|
        result.push(wrap_arg(arg, tys[idx], funcs, &block))
      }
      result
    end

    def wrap_arg(arg, ty, funcs = [], &block)

	
        funcs ||= []
        case arg
        when nil
          return 0
        when CPtr
          return arg.to_i
        when IO
          case ty
          when TYPE_VOIDP
            return CPtr[arg].to_i
          else
            return arg.to_i
          end
        when Function
          if( block )
            arg.bind_at_call(&block)
            funcs.push(arg)
          elsif !arg.bound?
            raise(RuntimeError, "block must be given.")
          end
          return arg.to_i
        when String
          if( ty.is_a?(Array) )
            return arg.unpack('C*')
          else
            case SIZEOF_VOIDP
            when SIZEOF_LONG
              return [arg].pack("p").unpack("l!")[0]
            when SIZEOF_LONG_LONG
              return [arg].pack("p").unpack("q")[0]
            else
              raise(RuntimeError, "sizeof(void*)?")
            end
          end
        when Float, Integer
          return arg
        when Array
          if( ty.is_a?(Array) ) # used only by struct
            case ty[0]
            when TYPE_VOIDP
              return arg.collect{|v| Integer(v)}
            when TYPE_CHAR
              if( arg.is_a?(String) )
                return val.unpack('C*')
              end
            end
            return arg
          else
            return arg
          end
        else
          if( arg.respond_to?(:to_ptr) )
            return arg.to_ptr.to_i
          else
            begin
              return Integer(arg)
            rescue
              raise(ArgumentError, "unknown argument type: #{arg.class}")
            end
          end
        end
    end
  end
end


module DL
  class Function < Object
    include DL
    include ValueUtil

    def initialize cfunc, argtypes, abi = nil, &block
      @cfunc = cfunc
      @stack = Stack.new(argtypes.collect{|ty| ty.abs})
      if( @cfunc.ctype < 0 )
        @cfunc.ctype = @cfunc.ctype.abs
        @unsigned = true
      else
        @unsigned = false
      end
      if block_given?
        bind(&block)
      end
    end

    def to_i()
      @cfunc.to_i
    end

    def name
      @cfunc.name
    end

    def call(*args, &block)
      funcs = []
      _args = wrap_args(args, @stack.types, funcs, &block)
      r = @cfunc.call(@stack.pack(_args))
      funcs.each{|f| f.unbind_at_call()}
      return wrap_result(r)
    end

    def wrap_result(r)
      case @cfunc.ctype
      when TYPE_VOIDP
        r = CPtr.new(r)
      else
        if( @unsigned )
          r = unsigned_value(r, @cfunc.ctype)
        end
      end
      r
    end

    def bind(&block)
      if( !block )
        raise(RuntimeError, "block must be given.")
      end
      if( @cfunc.ptr == 0 )
        cb = Proc.new{|*args|
          ary = @stack.unpack(args)
          @stack.types.each_with_index{|ty, idx|
            case ty
            when TYPE_VOIDP
              ary[idx] = CPtr.new(ary[idx])
            end
          }
          r = block.call(*ary)
          wrap_arg(r, @cfunc.ctype, [])
        }
        case @cfunc.calltype
        when :cdecl
          @cfunc.ptr = set_cdecl_callback(@cfunc.ctype, @stack.size, &cb)
        when :stdcall
          @cfunc.ptr = set_stdcall_callback(@cfunc.ctype, @stack.size, &cb)
        else
          raise(RuntimeError, "unsupported calltype: #{@cfunc.calltype}")
        end
        if( @cfunc.ptr == 0 )
          raise(RuntimeException, "can't bind C function.")
        end
      end
    end

    def unbind()
      if( @cfunc.ptr != 0 )
        case @cfunc.calltype
        when :cdecl
          remove_cdecl_callback(@cfunc.ptr, @cfunc.ctype)
        when :stdcall
          remove_stdcall_callback(@cfunc.ptr, @cfunc.ctype)
        else
          raise(RuntimeError, "unsupported calltype: #{@cfunc.calltype}")
        end
        @cfunc.ptr = 0
      end
    end

    def bound?()
      @cfunc.ptr != 0
    end

    def bind_at_call(&block)
      bind(&block)
    end

    def unbind_at_call()
    end
  end

  class TempFunction < Function
    def bind_at_call(&block)
      bind(&block)
    end

    def unbind_at_call()
      unbind()
    end
  end

  class CarriedFunction < Function
    def initialize(cfunc, argtypes, n)
      super(cfunc, argtypes)
      @carrier = []
      @index = n
      @mutex = Mutex.new
    end

    def create_carrier(data)
      ary = []
      userdata = [ary, data]
      @mutex.lock()
      @carrier.push(userdata)
      return dlwrap(userdata)
    end

    def bind_at_call(&block)
      userdata = @carrier[-1]
      userdata[0].push(block)
      bind{|*args|
        ptr = args[@index]
        if( !ptr )
          raise(RuntimeError, "The index of userdata should be lower than #{args.size}.")
        end
        userdata = dlunwrap(Integer(ptr))
        args[@index] = userdata[1]
        userdata[0][0].call(*args)
      }
      @mutex.unlock()
    end
  end
end


module DL
  class CStruct
    def CStruct.entity_class()
      CStructEntity
    end
  end

  class CUnion
    def CUnion.entity_class()
      CUnionEntity
    end
  end

  module CStructBuilder
    def create(klass, types, members)
      new_class = Class.new(klass){
        define_method(:initialize){|addr|
          @entity = klass.entity_class.new(addr, types)
          @entity.assign_names(members)
        }
        define_method(:to_ptr){ @entity }
        define_method(:to_i){ @entity.to_i }
        members.each{|name|
          define_method(name){ @entity[name] }
          define_method(name + "="){|val| @entity[name] = val }
        }
      }
      size = klass.entity_class.size(types)
      new_class.module_eval(<<-EOS, __FILE__, __LINE__+1)
        def new_class.size()
          #{size}
        end
        def new_class.malloc()
          addr = DL.malloc(#{size})
          new(addr)
        end
      EOS
      return new_class
    end
    module_function :create
  end

  class CStructEntity < CPtr
    include PackInfo
    include ValueUtil

    def CStructEntity.malloc(types, func = nil)
      addr = DL.malloc(CStructEntity.size(types))
      CStructEntity.new(addr, types, func)
    end

    def CStructEntity.size(types)
      offset = 0
      max_align = 0
      types.each_with_index{|t,i|
        orig_offset = offset
        if( t.is_a?(Array) )
          align = PackInfo::ALIGN_MAP[t[0]]
          offset = PackInfo.align(orig_offset, align)
          size = offset - orig_offset
          offset += (PackInfo::SIZE_MAP[t[0]] * t[1])
        else
          align = PackInfo::ALIGN_MAP[t]
          offset = PackInfo.align(orig_offset, align)
          size = offset - orig_offset
          offset += PackInfo::SIZE_MAP[t]
        end
        if (max_align < align)
          max_align = align
        end
      }
      offset = PackInfo.align(offset, max_align)
      offset
    end

    def initialize(addr, types, func = nil)
      set_ctypes(types)
      super(addr, @size, func)
    end

    def assign_names(members)
      @members = members
    end

    def set_ctypes(types)
      @ctypes = types
      @offset = []
      offset = 0
      max_align = 0
      types.each_with_index{|t,i|
        orig_offset = offset
        if( t.is_a?(Array) )
          align = ALIGN_MAP[t[0]]
        else
          align = ALIGN_MAP[t]
        end
        offset = PackInfo.align(orig_offset, align)
        @offset[i] = offset
        if( t.is_a?(Array) )
          offset += (SIZE_MAP[t[0]] * t[1])
        else
          offset += SIZE_MAP[t]
        end
        if (max_align < align)
          max_align = align
        end
      }
      offset = PackInfo.align(offset, max_align)
      @size = offset
    end

    def [](name)
      idx = @members.index(name)
      if( idx.nil? )
        raise(ArgumentError, "no such member: #{name}")
      end
      ty = @ctypes[idx]
      if( ty.is_a?(Array) )
        r = super(@offset[idx], SIZE_MAP[ty[0]] * ty[1])
      else
        r = super(@offset[idx], SIZE_MAP[ty.abs])
      end
      packer = Packer.new([ty])
      val = packer.unpack([r])
      case ty
      when Array
        case ty[0]
        when TYPE_VOIDP
          val = val.collect{|v| CPtr.new(v)}
        end
      when TYPE_VOIDP
        val = CPtr.new(val[0])
      else
        val = val[0]
      end
      if( ty.is_a?(Integer) && (ty < 0) )
        return unsigned_value(val, ty)
      elsif( ty.is_a?(Array) && (ty[0] < 0) )
        return val.collect{|v| unsigned_value(v,ty[0])}
      else
        return val
      end
    end

    def []=(name, val)
      idx = @members.index(name)
      if( idx.nil? )
        raise(ArgumentError, "no such member: #{name}")
      end
      ty  = @ctypes[idx]
      packer = Packer.new([ty])
      val = wrap_arg(val, ty, [])
      buff = packer.pack([val].flatten())
      super(@offset[idx], buff.size, buff)
      if( ty.is_a?(Integer) && (ty < 0) )
        return unsigned_value(val, ty)
      elsif( ty.is_a?(Array) && (ty[0] < 0) )
        return val.collect{|v| unsigned_value(v,ty[0])}
      else
        return val
      end
    end

    def to_s()
      super(@size)
    end
  end

  class CUnionEntity < CStructEntity
    include PackInfo

    def CUnionEntity.malloc(types, func=nil)
      addr = DL.malloc(CUnionEntity.size(types))
      CUnionEntity.new(addr, types, func)
    end

    def CUnionEntity.size(types)
      size   = 0
      types.each_with_index{|t,i|
        if( t.is_a?(Array) )
          tsize = PackInfo::SIZE_MAP[t[0]] * t[1]
        else
          tsize = PackInfo::SIZE_MAP[t]
        end
        if( tsize > size )
          size = tsize
        end
      }
    end

    def set_ctypes(types)
      @ctypes = types
      @offset = []
      @size   = 0
      types.each_with_index{|t,i|
        @offset[i] = 0
        if( t.is_a?(Array) )
          size = SIZE_MAP[t[0]] * t[1]
        else
          size = SIZE_MAP[t]
        end
        if( size > @size )
          @size = size
        end
      }
    end
  end
end



module DL
  module CParser
    def parse_struct_signature(signature, tymap=nil)
      if( signature.is_a?(String) )
        signature = signature.split(/\s*,\s*/)
      end
      mems = []
      tys  = []
      signature.each{|msig|
        tks = msig.split(/\s+(\*)?/)
        ty = tks[0..-2].join(" ")
        member = tks[-1]

        case ty
        when /\[(\d+)\]/
          n = $1.to_i
          ty.gsub!(/\s*\[\d+\]/,"")
          ty = [ty, n]
        when /\[\]/
          ty.gsub!(/\s*\[\]/, "*")
        end

        case member
        when /\[(\d+)\]/
          ty = [ty, $1.to_i]
          member.gsub!(/\s*\[\d+\]/,"")
        when /\[\]/
          ty = ty + "*"
          member.gsub!(/\s*\[\]/, "")
        end

        mems.push(member)
        tys.push(parse_ctype(ty,tymap))
      }
      return tys, mems
    end

    def parse_signature(signature, tymap=nil)
      tymap ||= {}
      signature = signature.gsub(/\s+/, " ").strip
      case signature
      when /^([\w@\*\s]+)\(([\w\*\s\,\[\]]*)\)$/
        ret = $1
        (args = $2).strip!
        ret = ret.split(/\s+/)
        args = args.split(/\s*,\s*/)
        func = ret.pop
        if( func =~ /^\*/ )
          func.gsub!(/^\*+/,"")
          ret.push("*")
        end
        ret  = ret.join(" ")
        return [func, parse_ctype(ret, tymap), args.collect{|arg| parse_ctype(arg, tymap)}]
      else
        raise(RuntimeError,"can't parse the function prototype: #{signature}")
      end
    end

    def parse_ctype(ty, tymap=nil)
      tymap ||= {}
      case ty
      when Array
        return [parse_ctype(ty[0], tymap), ty[1]]
      when "void"
        return TYPE_VOID
      when "char"
        return TYPE_CHAR
      when "unsigned char"
        return  -TYPE_CHAR
      when "short"
        return TYPE_SHORT
      when "unsigned short"
        return -TYPE_SHORT
      when "int"
        return TYPE_INT
      when "unsigned int", 'uint'
        return -TYPE_INT
      when "long"
        return TYPE_LONG
      when "unsigned long"
        return -TYPE_LONG
      when "long long"
        if( defined?(TYPE_LONG_LONG) )
          return TYPE_LONG_LONG
        else
          raise(RuntimeError, "unsupported type: #{ty}")
        end
      when "unsigned long long"
        if( defined?(TYPE_LONG_LONG) )
          return -TYPE_LONG_LONG
        else
          raise(RuntimeError, "unsupported type: #{ty}")
        end
      when "float"
        return TYPE_FLOAT
      when "double"
        return TYPE_DOUBLE
      when /\*/, /\[\s*\]/
        return TYPE_VOIDP
      else
        if( tymap[ty] )
          return parse_ctype(tymap[ty], tymap)
        else
          raise(DLError, "unknown type: #{ty}")
        end
      end
    end
  end
end

module DL
  class CompositeHandler
    def initialize(handlers)
      @handlers = handlers
    end

    def handlers()
      @handlers
    end

    def sym(symbol)
      @handlers.each{|handle|
        if( handle )
          begin
            addr = handle.sym(symbol)
            return addr
          rescue DLError
          end
        end
      }
      return nil
    end

    def [](symbol)
      sym(symbol)
    end
  end

  # DL::Importer includes the means to dynamically load libraries and build
  # modules around them including calling extern functions within the C
  # library that has been loaded.
  #
  # == Example
  #
  #   require 'dl'
  #   require 'dl/import'
  #
  #   module LibSum
  #   	extend DL::Importer
  #   	dlload './libsum.so'
  #   	extern 'double sum(double*, int)'
  #   	extern 'double split(double)'
  #   end
	#
  module Importer
    include DL
    include CParser
    extend Importer

    def dlload(*libs)
      handles = libs.collect{|lib|
        case lib
        when nil
          nil
        when Handle
          lib
        when Importer
          lib.handlers
        else
          begin
            DL.dlopen(lib)
          rescue DLError
            raise(DLError, "can't load #{lib}")
          end
        end
      }.flatten()
      @handler = CompositeHandler.new(handles)
      @func_map = {}
      @type_alias = {}
    end

    def typealias(alias_type, orig_type)
      @type_alias[alias_type] = orig_type
    end

    def sizeof(ty)
      case ty
      when String
        ty = parse_ctype(ty, @type_alias).abs()
        case ty
        when TYPE_CHAR
          return SIZEOF_CHAR
        when TYPE_SHORT
          return SIZEOF_SHORT
        when TYPE_INT
          return SIZEOF_INT
        when TYPE_LONG
          return SIZEOF_LONG
        when TYPE_LONG_LONG
          return SIZEOF_LONG_LON
        when TYPE_FLOAT
          return SIZEOF_FLOAT
        when TYPE_DOUBLE
          return SIZEOF_DOUBLE
        when TYPE_VOIDP
          return SIZEOF_VOIDP
        else
          raise(DLError, "unknown type: #{ty}")
        end
      when Class
        if( ty.instance_methods().include?(:to_ptr) )
          return ty.size()
        end
      end
      return CPtr[ty].size()
    end

    def parse_bind_options(opts)
      h = {}
      while( opt = opts.shift() )
        case opt
        when :stdcall, :cdecl
          h[:call_type] = opt
        when :carried, :temp, :temporal, :bind
          h[:callback_type] = opt
          h[:carrier] = opts.shift()
	else
          h[opt] = true
        end
      end
      h
    end
    private :parse_bind_options

    def extern(signature, *opts)
      symname, ctype, argtype = parse_signature(signature, @type_alias)
      opt = parse_bind_options(opts)
      f = import_function(symname, ctype, argtype, opt[:call_type])
      name = symname.gsub(/@.+/,'')
      @func_map[name] = f
      # define_method(name){|*args,&block| f.call(*args,&block)}
      begin
        /^(.+?):(\d+)/ =~ caller.first
        file, line = $1, $2.to_i
      rescue
        file, line = __FILE__, __LINE__+3
      end
      module_eval(<<-EOS, file, line)
        def #{name}(*args, &block)
          @func_map['#{name}'].call(*args,&block)
        end
      EOS
      module_function(name)
      f
    end

    def bind(signature, *opts, &blk)
      name, ctype, argtype = parse_signature(signature, @type_alias)
      h = parse_bind_options(opts)
      case h[:callback_type]
      when :bind, nil
        f = bind_function(name, ctype, argtype, h[:call_type], &blk)
      when :temp, :temporal
        f = create_temp_function(name, ctype, argtype, h[:call_type])
      when :carried
        f = create_carried_function(name, ctype, argtype, h[:call_type], h[:carrier])
      else
        raise(RuntimeError, "unknown callback type: #{h[:callback_type]}")
      end
      @func_map[name] = f
      #define_method(name){|*args,&block| f.call(*args,&block)}
      begin
        /^(.+?):(\d+)/ =~ caller.first
        file, line = $1, $2.to_i
      rescue
        file, line = __FILE__, __LINE__+3
      end
      module_eval(<<-EOS, file, line)
        def #{name}(*args,&block)
          @func_map['#{name}'].call(*args,&block)
        end
      EOS
      module_function(name)
      f
    end

    def struct(signature)
      tys, mems = parse_struct_signature(signature, @type_alias)
      DL::CStructBuilder.create(CStruct, tys, mems)
    end

    def union(signature)
      tys, mems = parse_struct_signature(signature, @type_alias)
      DL::CStructBuilder.create(CUnion, tys, mems)
    end

    def [](name)
      @func_map[name]
    end

    def create_value(ty, val=nil)
      s = struct([ty + " value"])
      ptr = s.malloc()
      if( val )
        ptr.value = val
      end
      return ptr
    end
    alias value create_value

    def import_value(ty, addr)
      s = struct([ty + " value"])
      ptr = s.new(addr)
      return ptr
    end

    def handler
      @handler or raise "call dlload before importing symbols and functions"
    end

    def import_symbol(name)
      addr = handler.sym(name)
      if( !addr )
        raise(DLError, "cannot find the symbol: #{name}")
      end
      CPtr.new(addr)
    end

    def import_function(name, ctype, argtype, call_type = nil)
      addr = handler.sym(name)
      if( !addr )
        raise(DLError, "cannot find the function: #{name}()")
      end
      Function.new(CFunc.new(addr, ctype, name, call_type || :cdecl), argtype)
    end

    def bind_function(name, ctype, argtype, call_type = nil, &block)
      if DL.fiddle?
        closure = Class.new(Fiddle::Closure) {
          define_method(:call, block)
        }.new(ctype, argtype)

        Function.new(closure, argtype)
      else
        f = Function.new(CFunc.new(0, ctype, name, call_type || :cdecl), argtype)
        f.bind(&block)
        f
      end
    end

    def create_temp_function(name, ctype, argtype, call_type = nil)
      TempFunction.new(CFunc.new(0, ctype, name, call_type || :cdecl), argtype)
    end

    def create_carried_function(name, ctype, argtype, call_type = nil, n = 0)
      CarriedFunction.new(CFunc.new(0, ctype, name, call_type || :cdecl), argtype, n)
    end
  end
end

#===============================================================================
# SOLOUD START
#===============================================================================

module SoLoudImporter
	extend DL::Importer
	dlload 'system/soloud_x86.dll'

	# Enumerations
	FFTFILTER_OVER=0
	SOLOUD_WASAPI=6
	SOLOUD_AUTO=0
	BIQUADRESONANTFILTER_NONE=0
	SOLOUD_CLIP_ROUNDOFF=1
	LOFIFILTER_BITDEPTH=2
	SOLOUD_SDL2=2
	SFXR_HURT=4
	FFTFILTER_MULTIPLY=2
	SOLOUD_ENABLE_VISUALIZATION=2
	BIQUADRESONANTFILTER_HIGHPASS=2
	SFXR_LASER=1
	SFXR_BLIP=6
	SFXR_JUMP=5
	LOFIFILTER_WET=0
	BIQUADRESONANTFILTER_WET=0
	LOFIFILTER_SAMPLERATE=1
	SOLOUD_SDL=1
	BIQUADRESONANTFILTER_LOWPASS=1
	SFXR_COIN=0
	FLANGERFILTER_FREQ=2
	SOLOUD_PORTAUDIO=3
	BIQUADRESONANTFILTER_SAMPLERATE=1
	SFXR_EXPLOSION=2
	BIQUADRESONANTFILTER_BANDPASS=3
	SOLOUD_OPENAL=8
	FLANGERFILTER_WET=0
	BIQUADRESONANTFILTER_FREQUENCY=2
	SFXR_POWERUP=3
	FFTFILTER_SUBTRACT=1
	SOLOUD_BACKEND_MAX=9
	BIQUADRESONANTFILTER_RESONANCE=3
	SOLOUD_XAUDIO2=5
	FLANGERFILTER_DELAY=1
	SOLOUD_WINMM=4
	SOLOUD_OSS=7

	# Raw DLL functions
	extern "void Soloud_destroy(Soloud *)"
	extern "Soloud * Soloud_create()"
	extern "int Soloud_init(Soloud *)"
	extern "int Soloud_initEx(Soloud *, unsigned int, unsigned int, unsigned int, unsigned int)"
	extern "void Soloud_deinit(Soloud *)"
	extern "unsigned int Soloud_getVersion(Soloud *)"
	extern "const char * Soloud_getErrorString(Soloud *, int)"
	extern "unsigned int Soloud_play(Soloud *, AudioSource *)"
	extern "unsigned int Soloud_playEx(Soloud *, AudioSource *, float, float, int, unsigned int)"
	extern "unsigned int Soloud_playClocked(Soloud *, double, AudioSource *)"
	extern "unsigned int Soloud_playClockedEx(Soloud *, double, AudioSource *, float, float, unsigned int)"
	extern "void Soloud_seek(Soloud *, unsigned int, double)"
	extern "void Soloud_stop(Soloud *, unsigned int)"
	extern "void Soloud_stopAll(Soloud *)"
	extern "void Soloud_stopAudioSource(Soloud *, AudioSource *)"
	extern "void Soloud_setFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int, float)"
	extern "float Soloud_getFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int)"
	extern "void Soloud_fadeFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int, float, double)"
	extern "void Soloud_oscillateFilterParameter(Soloud *, unsigned int, unsigned int, unsigned int, float, float, double)"
	extern "double Soloud_getStreamTime(Soloud *, unsigned int)"
	extern "int Soloud_getPause(Soloud *, unsigned int)"
	extern "float Soloud_getVolume(Soloud *, unsigned int)"
	extern "float Soloud_getPan(Soloud *, unsigned int)"
	extern "float Soloud_getSamplerate(Soloud *, unsigned int)"
	extern "int Soloud_getProtectVoice(Soloud *, unsigned int)"
	extern "unsigned int Soloud_getActiveVoiceCount(Soloud *)"
	extern "int Soloud_isValidVoiceHandle(Soloud *, unsigned int)"
	extern "float Soloud_getRelativePlaySpeed(Soloud *, unsigned int)"
	extern "float Soloud_getPostClipScaler(Soloud *)"
	extern "float Soloud_getGlobalVolume(Soloud *)"
	extern "void Soloud_setGlobalVolume(Soloud *, float)"
	extern "void Soloud_setPostClipScaler(Soloud *, float)"
	extern "void Soloud_setPause(Soloud *, unsigned int, int)"
	extern "void Soloud_setPauseAll(Soloud *, int)"
	extern "void Soloud_setRelativePlaySpeed(Soloud *, unsigned int, float)"
	extern "void Soloud_setProtectVoice(Soloud *, unsigned int, int)"
	extern "void Soloud_setSamplerate(Soloud *, unsigned int, float)"
	extern "void Soloud_setPan(Soloud *, unsigned int, float)"
	extern "void Soloud_setPanAbsolute(Soloud *, unsigned int, float, float)"
	extern "void Soloud_setVolume(Soloud *, unsigned int, float)"
	extern "void Soloud_setDelaySamples(Soloud *, unsigned int, unsigned int)"
	extern "void Soloud_fadeVolume(Soloud *, unsigned int, float, double)"
	extern "void Soloud_fadePan(Soloud *, unsigned int, float, double)"
	extern "void Soloud_fadeRelativePlaySpeed(Soloud *, unsigned int, float, double)"
	extern "void Soloud_fadeGlobalVolume(Soloud *, float, double)"
	extern "void Soloud_schedulePause(Soloud *, unsigned int, double)"
	extern "void Soloud_scheduleStop(Soloud *, unsigned int, double)"
	extern "void Soloud_oscillateVolume(Soloud *, unsigned int, float, float, double)"
	extern "void Soloud_oscillatePan(Soloud *, unsigned int, float, float, double)"
	extern "void Soloud_oscillateRelativePlaySpeed(Soloud *, unsigned int, float, float, double)"
	extern "void Soloud_oscillateGlobalVolume(Soloud *, float, float, double)"
	extern "void Soloud_setGlobalFilter(Soloud *, unsigned int, Filter *)"
	extern "void Soloud_setVisualizationEnable(Soloud *, int)"
	extern "float * Soloud_calcFFT(Soloud *)"
	extern "float * Soloud_getWave(Soloud *)"
	extern "unsigned int Soloud_getLoopCount(Soloud *, unsigned int)"
	extern "unsigned int Soloud_createVoiceGroup(Soloud *)"
	extern "int Soloud_destroyVoiceGroup(Soloud *, unsigned int)"
	extern "int Soloud_addVoiceToGroup(Soloud *, unsigned int, unsigned int)"
	extern "int Soloud_isVoiceGroup(Soloud *, unsigned int)"
	extern "int Soloud_isVoiceGroupEmpty(Soloud *, unsigned int)"
	extern "void BiquadResonantFilter_destroy(BiquadResonantFilter *)"
	extern "BiquadResonantFilter * BiquadResonantFilter_create()"
	extern "int BiquadResonantFilter_setParams(BiquadResonantFilter *, int, float, float, float)"
	extern "void Bus_destroy(Bus *)"
	extern "Bus * Bus_create()"
	extern "void Bus_setFilter(Bus *, unsigned int, Filter *)"
	extern "unsigned int Bus_play(Bus *, AudioSource *)"
	extern "unsigned int Bus_playEx(Bus *, AudioSource *, float, float, int)"
	extern "unsigned int Bus_playClocked(Bus *, double, AudioSource *)"
	extern "unsigned int Bus_playClockedEx(Bus *, double, AudioSource *, float, float)"
	extern "void Bus_setVisualizationEnable(Bus *, int)"
	extern "float * Bus_calcFFT(Bus *)"
	extern "float * Bus_getWave(Bus *)"
	extern "void Bus_setLooping(Bus *, int)"
	extern "void Bus_stop(Bus *)"
	extern "void EchoFilter_destroy(EchoFilter *)"
	extern "EchoFilter * EchoFilter_create()"
	extern "int EchoFilter_setParams(EchoFilter *, float)"
	extern "int EchoFilter_setParamsEx(EchoFilter *, float, float, float)"
	extern "void FFTFilter_destroy(FFTFilter *)"
	extern "FFTFilter * FFTFilter_create()"
	extern "int FFTFilter_setParameters(FFTFilter *, int)"
	extern "int FFTFilter_setParametersEx(FFTFilter *, int, int, float)"
	extern "void FlangerFilter_destroy(FlangerFilter *)"
	extern "FlangerFilter * FlangerFilter_create()"
	extern "int FlangerFilter_setParams(FlangerFilter *, float, float)"
	extern "void LofiFilter_destroy(LofiFilter *)"
	extern "LofiFilter * LofiFilter_create()"
	extern "int LofiFilter_setParams(LofiFilter *, float, float)"
	extern "void Modplug_destroy(Modplug *)"
	extern "Modplug * Modplug_create()"
	extern "int Modplug_load(Modplug *, const char *)"
	extern "void Modplug_setLooping(Modplug *, int)"
	extern "void Modplug_setFilter(Modplug *, unsigned int, Filter *)"
	extern "void Modplug_stop(Modplug *)"
	extern "void Prg_destroy(Prg *)"
	extern "Prg * Prg_create()"
	extern "unsigned int Prg_rand(Prg *)"
	extern "void Prg_srand(Prg *, int)"
	extern "void Sfxr_destroy(Sfxr *)"
	extern "Sfxr * Sfxr_create()"
	extern "void Sfxr_resetParams(Sfxr *)"
	extern "int Sfxr_loadParams(Sfxr *, const char *)"
	extern "int Sfxr_loadPreset(Sfxr *, int, int)"
	extern "void Sfxr_setLooping(Sfxr *, int)"
	extern "void Sfxr_setFilter(Sfxr *, unsigned int, Filter *)"
	extern "void Sfxr_stop(Sfxr *)"
	extern "void Speech_destroy(Speech *)"
	extern "Speech * Speech_create()"
	extern "int Speech_setText(Speech *, const char *)"
	extern "void Speech_setLooping(Speech *, int)"
	extern "void Speech_setFilter(Speech *, unsigned int, Filter *)"
	extern "void Speech_stop(Speech *)"
	extern "void Wav_destroy(Wav *)"
	extern "Wav * Wav_create()"
	extern "int Wav_load(Wav *, const char *)"
	extern "int Wav_loadMem(Wav *, unsigned char *, unsigned int)"
	extern "double Wav_getLength(Wav *)"
	extern "void Wav_setLooping(Wav *, int)"
	extern "void Wav_setFilter(Wav *, unsigned int, Filter *)"
	extern "void Wav_stop(Wav *)"
	extern "void WavStream_destroy(WavStream *)"
	extern "WavStream * WavStream_create()"
	extern "int WavStream_load(WavStream *, const char *)"
	extern "double WavStream_getLength(WavStream *)"
	extern "void WavStream_setLooping(WavStream *, int)"
	extern "void WavStream_setFilter(WavStream *, unsigned int, Filter *)"
	extern "void WavStream_stop(WavStream *)"
end


# OOP wrappers

class Soloud
	@objhandle=nil
	attr_accessor :objhandle
	WASAPI=6
	AUTO=0
	CLIP_ROUNDOFF=1
	SDL2=2
	ENABLE_VISUALIZATION=2
	SDL=1
	PORTAUDIO=3
	OPENAL=8
	BACKEND_MAX=9
	XAUDIO2=5
	WINMM=4
	OSS=7
	def initialize(*args)
		@objhandle = SoLoudImporter.Soloud_create()
	end
	def destroy()
		SoLoudImporter.Soloud_destroy(@objhandle)
	end
	def init(aFlags=CLIP_ROUNDOFF, aBackend=AUTO, aSamplerate=AUTO, aBufferSize=AUTO)
		SoLoudImporter.Soloud_initEx(@objhandle, aFlags, aBackend, aSamplerate, aBufferSize)
	end
	def deinit()
		SoLoudImporter.Soloud_deinit(@objhandle)
	end
	def get_version()
		SoLoudImporter.Soloud_getVersion(@objhandle)
	end
	def get_error_string(aErrorCode)
		SoLoudImporter.Soloud_getErrorString(@objhandle, aErrorCode)
	end
	def play(aSound, aVolume=1.0, aPan=0.0, aPaused=0, aBus=0)
		SoLoudImporter.Soloud_playEx(@objhandle, aSound.objhandle, aVolume, aPan, aPaused, aBus)
	end
	def play_clocked(aSoundTime, aSound, aVolume=1.0, aPan=0.0, aBus=0)
		SoLoudImporter.Soloud_playClockedEx(@objhandle, aSoundTime, aSound.objhandle, aVolume, aPan, aBus)
	end
	def seek(aVoiceHandle, aSeconds)
		SoLoudImporter.Soloud_seek(@objhandle, aVoiceHandle, aSeconds)
	end
	def stop(aVoiceHandle)
		SoLoudImporter.Soloud_stop(@objhandle, aVoiceHandle)
	end
	def stop_all()
		SoLoudImporter.Soloud_stopAll(@objhandle)
	end
	def stop_audio_source(aSound)
		SoLoudImporter.Soloud_stopAudioSource(@objhandle, aSound.objhandle)
	end
	def set_filter_parameter(aVoiceHandle, aFilterId, aAttributeId, aValue)
		SoLoudImporter.Soloud_setFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId, aValue)
	end
	def get_filter_parameter(aVoiceHandle, aFilterId, aAttributeId)
		SoLoudImporter.Soloud_getFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId)
	end
	def fade_filter_parameter(aVoiceHandle, aFilterId, aAttributeId, aTo, aTime)
		SoLoudImporter.Soloud_fadeFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId, aTo, aTime)
	end
	def oscillate_filter_parameter(aVoiceHandle, aFilterId, aAttributeId, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateFilterParameter(@objhandle, aVoiceHandle, aFilterId, aAttributeId, aFrom, aTo, aTime)
	end
	def get_stream_time(aVoiceHandle)
		SoLoudImporter.Soloud_getStreamTime(@objhandle, aVoiceHandle)
	end
	def get_pause(aVoiceHandle)
		SoLoudImporter.Soloud_getPause(@objhandle, aVoiceHandle)
	end
	def get_volume(aVoiceHandle)
		SoLoudImporter.Soloud_getVolume(@objhandle, aVoiceHandle)
	end
	def get_pan(aVoiceHandle)
		SoLoudImporter.Soloud_getPan(@objhandle, aVoiceHandle)
	end
	def get_samplerate(aVoiceHandle)
		SoLoudImporter.Soloud_getSamplerate(@objhandle, aVoiceHandle)
	end
	def get_protect_voice(aVoiceHandle)
		SoLoudImporter.Soloud_getProtectVoice(@objhandle, aVoiceHandle)
	end
	def get_active_voice_count()
		SoLoudImporter.Soloud_getActiveVoiceCount(@objhandle)
	end
	def is_valid_voice_handle(aVoiceHandle)
		SoLoudImporter.Soloud_isValidVoiceHandle(@objhandle, aVoiceHandle)
	end
	def get_relative_play_speed(aVoiceHandle)
		SoLoudImporter.Soloud_getRelativePlaySpeed(@objhandle, aVoiceHandle)
	end
	def get_post_clip_scaler()
		SoLoudImporter.Soloud_getPostClipScaler(@objhandle)
	end
	def get_global_volume()
		SoLoudImporter.Soloud_getGlobalVolume(@objhandle)
	end
	def set_global_volume(aVolume)
		SoLoudImporter.Soloud_setGlobalVolume(@objhandle, aVolume)
	end
	def set_post_clip_scaler(aScaler)
		SoLoudImporter.Soloud_setPostClipScaler(@objhandle, aScaler)
	end
	def set_pause(aVoiceHandle, aPause)
		SoLoudImporter.Soloud_setPause(@objhandle, aVoiceHandle, aPause)
	end
	def set_pause_all(aPause)
		SoLoudImporter.Soloud_setPauseAll(@objhandle, aPause)
	end
	def set_relative_play_speed(aVoiceHandle, aSpeed)
		SoLoudImporter.Soloud_setRelativePlaySpeed(@objhandle, aVoiceHandle, aSpeed)
	end
	def set_protect_voice(aVoiceHandle, aProtect)
		SoLoudImporter.Soloud_setProtectVoice(@objhandle, aVoiceHandle, aProtect)
	end
	def set_samplerate(aVoiceHandle, aSamplerate)
		SoLoudImporter.Soloud_setSamplerate(@objhandle, aVoiceHandle, aSamplerate)
	end
	def set_pan(aVoiceHandle, aPan)
		SoLoudImporter.Soloud_setPan(@objhandle, aVoiceHandle, aPan)
	end
	def set_pan_absolute(aVoiceHandle, aLVolume, aRVolume)
		SoLoudImporter.Soloud_setPanAbsolute(@objhandle, aVoiceHandle, aLVolume, aRVolume)
	end
	def set_volume(aVoiceHandle, aVolume)
		SoLoudImporter.Soloud_setVolume(@objhandle, aVoiceHandle, aVolume)
	end
	def set_delay_samples(aVoiceHandle, aSamples)
		SoLoudImporter.Soloud_setDelaySamples(@objhandle, aVoiceHandle, aSamples)
	end
	def fade_volume(aVoiceHandle, aTo, aTime)
		SoLoudImporter.Soloud_fadeVolume(@objhandle, aVoiceHandle, aTo, aTime)
	end
	def fade_pan(aVoiceHandle, aTo, aTime)
		SoLoudImporter.Soloud_fadePan(@objhandle, aVoiceHandle, aTo, aTime)
	end
	def fade_relative_play_speed(aVoiceHandle, aTo, aTime)
		SoLoudImporter.Soloud_fadeRelativePlaySpeed(@objhandle, aVoiceHandle, aTo, aTime)
	end
	def fade_global_volume(aTo, aTime)
		SoLoudImporter.Soloud_fadeGlobalVolume(@objhandle, aTo, aTime)
	end
	def schedule_pause(aVoiceHandle, aTime)
		SoLoudImporter.Soloud_schedulePause(@objhandle, aVoiceHandle, aTime)
	end
	def schedule_stop(aVoiceHandle, aTime)
		SoLoudImporter.Soloud_scheduleStop(@objhandle, aVoiceHandle, aTime)
	end
	def oscillate_volume(aVoiceHandle, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateVolume(@objhandle, aVoiceHandle, aFrom, aTo, aTime)
	end
	def oscillate_pan(aVoiceHandle, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillatePan(@objhandle, aVoiceHandle, aFrom, aTo, aTime)
	end
	def oscillate_relative_play_speed(aVoiceHandle, aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateRelativePlaySpeed(@objhandle, aVoiceHandle, aFrom, aTo, aTime)
	end
	def oscillate_global_volume(aFrom, aTo, aTime)
		SoLoudImporter.Soloud_oscillateGlobalVolume(@objhandle, aFrom, aTo, aTime)
	end
	def set_global_filter(aFilterId, aFilter)
		SoLoudImporter.Soloud_setGlobalFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def set_visualization_enable(aEnable)
		SoLoudImporter.Soloud_setVisualizationEnable(@objhandle, aEnable)
	end
	def calc_fft()
		SoLoudImporter.Soloud_calcFFT(@objhandle)
	end
	def get_wave()
		SoLoudImporter.Soloud_getWave(@objhandle)
	end
	def get_loop_count(aVoiceHandle)
		SoLoudImporter.Soloud_getLoopCount(@objhandle, aVoiceHandle)
	end
	def create_voice_group()
		SoLoudImporter.Soloud_createVoiceGroup(@objhandle)
	end
	def destroy_voice_group(aVoiceGroupHandle)
		SoLoudImporter.Soloud_destroyVoiceGroup(@objhandle, aVoiceGroupHandle)
	end
	def add_voice_to_group(aVoiceGroupHandle, aVoiceHandle)
		SoLoudImporter.Soloud_addVoiceToGroup(@objhandle, aVoiceGroupHandle, aVoiceHandle)
	end
	def is_voice_group(aVoiceGroupHandle)
		SoLoudImporter.Soloud_isVoiceGroup(@objhandle, aVoiceGroupHandle)
	end
	def is_voice_group_empty(aVoiceGroupHandle)
		SoLoudImporter.Soloud_isVoiceGroupEmpty(@objhandle, aVoiceGroupHandle)
	end
end

class BiquadResonantFilter
	@objhandle=nil
	attr_accessor :objhandle
	NONE=0
	HIGHPASS=2
	WET=0
	LOWPASS=1
	SAMPLERATE=1
	BANDPASS=3
	FREQUENCY=2
	RESONANCE=3
	def initialize(*args)
		@objhandle = SoLoudImporter.BiquadResonantFilter_create()
	end
	def destroy()
		SoLoudImporter.BiquadResonantFilter_destroy(@objhandle)
	end
	def set_params(aType, aSampleRate, aFrequency, aResonance)
		SoLoudImporter.BiquadResonantFilter_setParams(@objhandle, aType, aSampleRate, aFrequency, aResonance)
	end
end

class Bus
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(*args)
		@objhandle = SoLoudImporter.Bus_create()
	end
	def destroy()
		SoLoudImporter.Bus_destroy(@objhandle)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Bus_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def play(aSound, aVolume=1.0, aPan=0.0, aPaused=0)
		SoLoudImporter.Bus_playEx(@objhandle, aSound.objhandle, aVolume, aPan, aPaused)
	end
	def play_clocked(aSoundTime, aSound, aVolume=1.0, aPan=0.0)
		SoLoudImporter.Bus_playClockedEx(@objhandle, aSoundTime, aSound.objhandle, aVolume, aPan)
	end
	def set_visualization_enable(aEnable)
		SoLoudImporter.Bus_setVisualizationEnable(@objhandle, aEnable)
	end
	def calc_fft()
		SoLoudImporter.Bus_calcFFT(@objhandle)
	end
	def get_wave()
		SoLoudImporter.Bus_getWave(@objhandle)
	end
	def set_looping(aLoop)
		SoLoudImporter.Bus_setLooping(@objhandle, aLoop)
	end
	def stop()
		SoLoudImporter.Bus_stop(@objhandle)
	end
end

class EchoFilter
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(*args)
		@objhandle = SoLoudImporter.EchoFilter_create()
	end
	def destroy()
		SoLoudImporter.EchoFilter_destroy(@objhandle)
	end
	def set_params(aDelay, aDecay=0.7, aFilter=0.0)
		SoLoudImporter.EchoFilter_setParamsEx(@objhandle, aDelay, aDecay, aFilter)
	end
end

class FFTFilter
	@objhandle=nil
	attr_accessor :objhandle
	OVER=0
	MULTIPLY=2
	SUBTRACT=1
	def initialize(*args)
		@objhandle = SoLoudImporter.FFTFilter_create()
	end
	def destroy()
		SoLoudImporter.FFTFilter_destroy(@objhandle)
	end
	def set_parameters(aShift, aCombine=0, aScale=0.002)
		SoLoudImporter.FFTFilter_setParametersEx(@objhandle, aShift, aCombine, aScale)
	end
end

class FlangerFilter
	@objhandle=nil
	attr_accessor :objhandle
	FREQ=2
	WET=0
	DELAY=1
	def initialize(*args)
		@objhandle = SoLoudImporter.FlangerFilter_create()
	end
	def destroy()
		SoLoudImporter.FlangerFilter_destroy(@objhandle)
	end
	def set_params(aDelay, aFreq)
		SoLoudImporter.FlangerFilter_setParams(@objhandle, aDelay, aFreq)
	end
end

class LofiFilter
	@objhandle=nil
	attr_accessor :objhandle
	BITDEPTH=2
	WET=0
	SAMPLERATE=1
	def initialize(*args)
		@objhandle = SoLoudImporter.LofiFilter_create()
	end
	def destroy()
		SoLoudImporter.LofiFilter_destroy(@objhandle)
	end
	def set_params(aSampleRate, aBitdepth)
		SoLoudImporter.LofiFilter_setParams(@objhandle, aSampleRate, aBitdepth)
	end
end

class Modplug
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(*args)
		@objhandle = SoLoudImporter.Modplug_create()
	end
	def destroy()
		SoLoudImporter.Modplug_destroy(@objhandle)
	end
	def load(aFilename)
		SoLoudImporter.Modplug_load(@objhandle, aFilename)
	end
	def set_looping(aLoop)
		SoLoudImporter.Modplug_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Modplug_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Modplug_stop(@objhandle)
	end
end

class Prg
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(*args)
		@objhandle = SoLoudImporter.Prg_create()
	end
	def destroy()
		SoLoudImporter.Prg_destroy(@objhandle)
	end
	def rand()
		SoLoudImporter.Prg_rand(@objhandle)
	end
	def srand(aSeed)
		SoLoudImporter.Prg_srand(@objhandle, aSeed)
	end
end

class Sfxr
	@objhandle=nil
	attr_accessor :objhandle
	HURT=4
	LASER=1
	BLIP=6
	JUMP=5
	COIN=0
	EXPLOSION=2
	POWERUP=3
	def initialize(*args)
		@objhandle = SoLoudImporter.Sfxr_create()
	end
	def destroy()
		SoLoudImporter.Sfxr_destroy(@objhandle)
	end
	def reset_params()
		SoLoudImporter.Sfxr_resetParams(@objhandle)
	end
	def load_params(aFilename)
		SoLoudImporter.Sfxr_loadParams(@objhandle, aFilename)
	end
	def load_preset(aPresetNo, aRandSeed)
		SoLoudImporter.Sfxr_loadPreset(@objhandle, aPresetNo, aRandSeed)
	end
	def set_looping(aLoop)
		SoLoudImporter.Sfxr_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Sfxr_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Sfxr_stop(@objhandle)
	end
end

class Speech
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(*args)
		@objhandle = SoLoudImporter.Speech_create()
	end
	def destroy()
		SoLoudImporter.Speech_destroy(@objhandle)
	end
	def set_text(aText)
		SoLoudImporter.Speech_setText(@objhandle, aText)
	end
	def set_looping(aLoop)
		SoLoudImporter.Speech_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Speech_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Speech_stop(@objhandle)
	end
end

class Wav
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(*args)
		@objhandle = SoLoudImporter.Wav_create()
	end
	def destroy()
		SoLoudImporter.Wav_destroy(@objhandle)
	end
	def load(aFilename)
		SoLoudImporter.Wav_load(@objhandle, aFilename)
	end
	def load_mem(aMem, aLength)
		SoLoudImporter.Wav_loadMem(@objhandle, aMem, aLength)
	end
	def get_length()
		SoLoudImporter.Wav_getLength(@objhandle)
	end
	def set_looping(aLoop)
		SoLoudImporter.Wav_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.Wav_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.Wav_stop(@objhandle)
	end
end

class WavStream
	@objhandle=nil
	attr_accessor :objhandle
	def initialize(*args)
		@objhandle = SoLoudImporter.WavStream_create()
	end
	def destroy()
		SoLoudImporter.WavStream_destroy(@objhandle)
	end
	def load(aFilename)
		SoLoudImporter.WavStream_load(@objhandle, aFilename)
	end
	def get_length()
		SoLoudImporter.WavStream_getLength(@objhandle)
	end
	def set_looping(aLoop)
		SoLoudImporter.WavStream_setLooping(@objhandle, aLoop)
	end
	def set_filter(aFilterId, aFilter)
		SoLoudImporter.WavStream_setFilter(@objhandle, aFilterId, aFilter.objhandle)
	end
	def stop()
		SoLoudImporter.WavStream_stop(@objhandle)
	end
end