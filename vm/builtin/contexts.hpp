#ifndef RBX_BUILTIN_CONTEXTS_HPP
#define RBX_BUILTIN_CONTEXTS_HPP

#include "objects.hpp"
#include "vmmethod.hpp"

namespace rubinius {
  class BlockContext;
  class MethodContext;
  class BlockEnvironment;

  class MethodContext : public Object {
    public:
    const static size_t fields = 0;
    const static object_type type = MContextType;

    MethodContext* sender; // slot
    MethodContext* home; // slot
    OBJECT self; // slot

    CompiledMethod* cm; // slot
    VMMethod* vmm;

    Module* module; // slot

    Tuple* stack; // slot

    int    ip;
    int    sp;
    size_t args;
    OBJECT block; // slot
    OBJECT name; // slot

    /* Locals are stored at the top of the stack. */
    Tuple* locals() { return stack; }

    static MethodContext* create(STATE);
    void reference(STATE);

    class Info : public TypeInfo {
    public:
      BASIC_TYPEINFO(TypeInfo)
    };
  };

  class BlockContext : public MethodContext {
    public:
    const static size_t fields = 0;
    const static object_type type = BContextType;

    BlockEnvironment* env();

    static BlockContext* create(STATE);

    class Info : public MethodContext::Info {
    public:
      BASIC_TYPEINFO(MethodContext::Info)
    };
  };

  template <>
    static bool kind_of<MethodContext>(OBJECT obj) {
      return obj->obj_type == MethodContext::type ||
        obj->obj_type == BlockContext::type;
    }

}

#endif
