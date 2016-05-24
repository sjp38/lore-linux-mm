Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A969E6B007E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 08:40:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so28222727pfz.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 05:40:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id l7si4520307pac.212.2016.05.24.05.39.57
        for <linux-mm@kvack.org>;
        Tue, 24 May 2016 05:39:58 -0700 (PDT)
Date: Tue, 24 May 2016 20:38:22 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 11903/11991] include/linux/tracepoint.h:183:21:
 error: invalid storage class for function
 'trace_mm_collapse_huge_page_swapin'
Message-ID: <201605242005.wbBcMRyw%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   66c198deda3725c57939c6cdaf2c9f5375cd79ad
commit: 94a7d3c1a7de6c62089012384e6be3286d4bfd43 [11903/11991] mm: make swapin readahead to improve thp collapse rate
config: i386-randconfig-h1-05241552 (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        git checkout 94a7d3c1a7de6c62089012384e6be3286d4bfd43
        # save the attached .config to linux build tree
        make ARCH=i386 

All error/warnings (new ones prefixed by >>):

    TRACE_EVENT(mm_collapse_huge_page_isolate,
    ^~~~~~~~~~~
   In file included from include/trace/events/huge_memory.h:7:0,
                    from mm/huge_memory.c:66:
   include/trace/events/huge_memory.h: In function 'page_is_young':
   include/linux/tracepoint.h:199:2: error: invalid storage class for function 'register_trace_mm_collapse_huge_page_isolate'
     register_trace_##name(void (*probe)(data_proto), void *data) \
     ^
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:107:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_isolate,
    ^~~~~~~~~~~
   include/linux/tracepoint.h:205:2: error: invalid storage class for function 'register_trace_prio_mm_collapse_huge_page_isolate'
     register_trace_prio_##name(void (*probe)(data_proto), void *data,\
     ^
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:107:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_isolate,
    ^~~~~~~~~~~
   include/linux/tracepoint.h:212:2: error: invalid storage class for function 'unregister_trace_mm_collapse_huge_page_isolate'
     unregister_trace_##name(void (*probe)(data_proto), void *data) \
     ^
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:107:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_isolate,
    ^~~~~~~~~~~
   include/linux/tracepoint.h:218:2: error: invalid storage class for function 'check_trace_callback_type_mm_collapse_huge_page_isolate'
     check_trace_callback_type_##name(void (*cb)(data_proto)) \
     ^
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:107:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_isolate,
    ^~~~~~~~~~~
   include/linux/tracepoint.h:222:2: error: invalid storage class for function 'trace_mm_collapse_huge_page_isolate_enabled'
     trace_##name##_enabled(void)     \
     ^
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:107:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_isolate,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h: In function 'trace_mm_collapse_huge_page_isolate_enabled':
   include/trace/events/huge_memory.h:109:18: error: invalid use of undefined type 'struct tracepoint'
     TP_PROTO(struct page *page, int none_or_zero,
                     ^
   include/linux/tracepoint.h:218:46: note: in definition of macro '__DECLARE_TRACE'
     check_trace_callback_type_##name(void (*cb)(data_proto)) \
                                                 ^~~~~~~~~~
   include/linux/tracepoint.h:350:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:484:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/huge_memory.h:107:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_isolate,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h:109:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(struct page *page, int none_or_zero,
     ^~~~~~~~
   include/trace/events/huge_memory.h: In function 'page_is_young':
   include/linux/tracepoint.h:182:2: warning: ISO C90 forbids mixed declarations and code [-Wdeclaration-after-statement]
     extern struct tracepoint __tracepoint_##name;   \
     ^
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
>> include/linux/tracepoint.h:183:21: error: invalid storage class for function 'trace_mm_collapse_huge_page_swapin'
     static inline void trace_##name(proto)    \
                        ^
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h: In function 'trace_mm_collapse_huge_page_swapin':
   include/trace/events/huge_memory.h:140:18: error: invalid use of undefined type 'struct tracepoint'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
                     ^
   include/linux/tracepoint.h:183:34: note: in definition of macro '__DECLARE_TRACE'
     static inline void trace_##name(proto)    \
                                     ^~~~~
   include/linux/tracepoint.h:348:24: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
                           ^~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:484:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h:140:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
     ^~~~~~~~
   include/trace/events/huge_memory.h:140:18: error: invalid use of undefined type 'struct tracepoint'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
                     ^
   include/linux/tracepoint.h:183:34: note: in definition of macro '__DECLARE_TRACE'
     static inline void trace_##name(proto)    \
                                     ^~~~~
   include/linux/tracepoint.h:348:24: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
                           ^~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:484:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h:140:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
     ^~~~~~~~
   In file included from include/asm-generic/bug.h:4:0,
                    from arch/x86/include/asm/bug.h:35,
                    from include/linux/bug.h:4,
                    from include/linux/mmdebug.h:4,
                    from include/linux/mm.h:8,
                    from mm/huge_memory.c:10:
   include/linux/compiler.h:154:17: error: invalid use of undefined type 'struct tracepoint'
      static struct ftrace_branch_data   \
                    ^
   include/linux/compiler.h:149:23: note: in expansion of macro '__trace_if'
    #define if(cond, ...) __trace_if( (cond , ## __VA_ARGS__) )
                          ^~~~~~~~~~
   include/linux/tracepoint.h:185:3: note: in expansion of macro 'if'
      if (static_key_false(&__tracepoint_##name.key))  \
      ^~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/linux/cpumask.h:93:42: error: invalid use of undefined type 'struct tracepoint'
    #define cpu_online_mask   ((const struct cpumask *)&__cpu_online_mask)
                                             ^
   include/linux/compiler.h:162:16: note: in definition of macro '__trace_if'
      ______r = !!(cond);     \
                   ^~~~
   include/linux/tracepoint.h:137:3: note: in expansion of macro 'if'
      if (!(cond))      \
      ^~
   include/linux/tracepoint.h:186:4: note: in expansion of macro '__DO_TRACE'
       __DO_TRACE(&__tracepoint_##name,  \
       ^~~~~~~~~~
   include/linux/tracepoint.h:189:5: note: in expansion of macro 'TP_CONDITION'
        TP_CONDITION(cond),,);   \
        ^~~~~~~~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/cpumask.h:102:50: note: in expansion of macro 'cpu_online_mask'
    #define cpu_online(cpu)  cpumask_test_cpu((cpu), cpu_online_mask)
                                                     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:349:4: note: in expansion of macro 'cpu_online'
--
                          ^~~~~~~~~~
   include/linux/compiler.h:285:2: note: in expansion of macro 'if'
     if (check)       \
     ^~
   include/linux/compiler.h:291:22: note: in expansion of macro '__READ_ONCE'
    #define READ_ONCE(x) __READ_ONCE(x, 1)
                         ^~~~~~~~~~~
   include/linux/compiler.h:551:26: note: in expansion of macro 'READ_ONCE'
     typeof(p) _________p1 = READ_ONCE(p); \
                             ^~~~~~~~~
   include/linux/rcupdate.h:603:48: note: in expansion of macro 'lockless_dereference'
     typeof(*p) *________p1 = (typeof(*p) *__force)lockless_dereference(p); \
                                                   ^~~~~~~~~~~~~~~~~~~~
   include/linux/rcupdate.h:729:2: note: in expansion of macro '__rcu_dereference_check'
     __rcu_dereference_check((p), (c) || rcu_read_lock_sched_held(), \
     ^~~~~~~~~~~~~~~~~~~~~~~
   include/linux/rcupdate.h:786:34: note: in expansion of macro 'rcu_dereference_sched_check'
    #define rcu_dereference_sched(p) rcu_dereference_sched_check(p, 0)
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:192:4: note: in expansion of macro 'rcu_dereference_sched'
       rcu_dereference_sched(__tracepoint_##name.funcs);\
       ^~~~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/linux/compiler.h:154:17: error: invalid use of undefined type 'struct tracepoint'
      static struct ftrace_branch_data   \
                    ^
   include/linux/compiler.h:149:23: note: in expansion of macro '__trace_if'
    #define if(cond, ...) __trace_if( (cond , ## __VA_ARGS__) )
                          ^~~~~~~~~~
   include/linux/compiler.h:285:2: note: in expansion of macro 'if'
     if (check)       \
     ^~
   include/linux/compiler.h:291:22: note: in expansion of macro '__READ_ONCE'
    #define READ_ONCE(x) __READ_ONCE(x, 1)
                         ^~~~~~~~~~~
   include/linux/compiler.h:551:26: note: in expansion of macro 'READ_ONCE'
     typeof(p) _________p1 = READ_ONCE(p); \
                             ^~~~~~~~~
   include/linux/rcupdate.h:603:48: note: in expansion of macro 'lockless_dereference'
     typeof(*p) *________p1 = (typeof(*p) *__force)lockless_dereference(p); \
                                                   ^~~~~~~~~~~~~~~~~~~~
   include/linux/rcupdate.h:729:2: note: in expansion of macro '__rcu_dereference_check'
     __rcu_dereference_check((p), (c) || rcu_read_lock_sched_held(), \
     ^~~~~~~~~~~~~~~~~~~~~~~
   include/linux/rcupdate.h:786:34: note: in expansion of macro 'rcu_dereference_sched_check'
    #define rcu_dereference_sched(p) rcu_dereference_sched_check(p, 0)
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:192:4: note: in expansion of macro 'rcu_dereference_sched'
       rcu_dereference_sched(__tracepoint_##name.funcs);\
       ^~~~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/linux/compiler.h:154:17: error: invalid use of undefined type 'struct tracepoint'
      static struct ftrace_branch_data   \
                    ^
   include/linux/compiler.h:149:23: note: in expansion of macro '__trace_if'
    #define if(cond, ...) __trace_if( (cond , ## __VA_ARGS__) )
                          ^~~~~~~~~~
   include/linux/rcupdate.h:544:3: note: in expansion of macro 'if'
      if (debug_lockdep_rcu_enabled() && !__warned && (c)) { \
      ^~
   include/linux/rcupdate.h:604:2: note: in expansion of macro 'RCU_LOCKDEP_WARN'
     RCU_LOCKDEP_WARN(!(c), "suspicious rcu_dereference_check() usage"); \
     ^~~~~~~~~~~~~~~~
   include/linux/rcupdate.h:729:2: note: in expansion of macro '__rcu_dereference_check'
     __rcu_dereference_check((p), (c) || rcu_read_lock_sched_held(), \
     ^~~~~~~~~~~~~~~~~~~~~~~
   include/linux/rcupdate.h:786:34: note: in expansion of macro 'rcu_dereference_sched_check'
    #define rcu_dereference_sched(p) rcu_dereference_sched_check(p, 0)
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:192:4: note: in expansion of macro 'rcu_dereference_sched'
       rcu_dereference_sched(__tracepoint_##name.funcs);\
       ^~~~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   In file included from include/trace/events/huge_memory.h:7:0,
                    from mm/huge_memory.c:66:
   include/trace/events/huge_memory.h: In function 'page_is_young':
>> include/linux/tracepoint.h:155:21: error: invalid storage class for function 'trace_mm_collapse_huge_page_swapin_rcuidle'
     static inline void trace_##name##_rcuidle(proto)  \
                        ^
   include/linux/tracepoint.h:196:2: note: in expansion of macro '__DECLARE_TRACE_RCU'
     __DECLARE_TRACE_RCU(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h: In function 'trace_mm_collapse_huge_page_swapin_rcuidle':
   include/trace/events/huge_memory.h:140:18: error: invalid use of undefined type 'struct tracepoint'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
                     ^
   include/linux/tracepoint.h:155:44: note: in definition of macro '__DECLARE_TRACE_RCU'
     static inline void trace_##name##_rcuidle(proto)  \
                                               ^~~~~
   include/linux/tracepoint.h:196:28: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE_RCU(name, PARAMS(proto), PARAMS(args),  \
                               ^~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:348:24: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
                           ^~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:484:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h:140:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
     ^~~~~~~~
   include/trace/events/huge_memory.h:140:18: error: invalid use of undefined type 'struct tracepoint'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
                     ^
   include/linux/tracepoint.h:155:44: note: in definition of macro '__DECLARE_TRACE_RCU'
     static inline void trace_##name##_rcuidle(proto)  \
                                               ^~~~~
   include/linux/tracepoint.h:196:28: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE_RCU(name, PARAMS(proto), PARAMS(args),  \
                               ^~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:348:24: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
                           ^~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:484:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/trace/events/huge_memory.h:140:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
     ^~~~~~~~
   In file included from include/asm-generic/bug.h:4:0,
                    from arch/x86/include/asm/bug.h:35,
                    from include/linux/bug.h:4,
                    from include/linux/mmdebug.h:4,
                    from include/linux/mm.h:8,
                    from mm/huge_memory.c:10:
   include/linux/compiler.h:154:17: error: invalid use of undefined type 'struct tracepoint'
      static struct ftrace_branch_data   \
                    ^
   include/linux/compiler.h:149:23: note: in expansion of macro '__trace_if'
    #define if(cond, ...) __trace_if( (cond , ## __VA_ARGS__) )
                          ^~~~~~~~~~
   include/linux/tracepoint.h:157:3: note: in expansion of macro 'if'
      if (static_key_false(&__tracepoint_##name.key))  \
      ^~
   include/linux/tracepoint.h:196:2: note: in expansion of macro '__DECLARE_TRACE_RCU'
     __DECLARE_TRACE_RCU(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~~~~~
   include/linux/tracepoint.h:348:2: note: in expansion of macro '__DECLARE_TRACE'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
     ^~~~~~~~~~~~~~~
   include/linux/tracepoint.h:484:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/trace/events/huge_memory.h:138:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_collapse_huge_page_swapin,
    ^~~~~~~~~~~
   include/linux/cpumask.h:93:42: error: invalid use of undefined type 'struct tracepoint'
    #define cpu_online_mask   ((const struct cpumask *)&__cpu_online_mask)
                                             ^
   include/linux/compiler.h:162:16: note: in definition of macro '__trace_if'
..

vim +/trace_mm_collapse_huge_page_swapin +183 include/linux/tracepoint.h

da7b3eab Mathieu Desnoyers        2008-11-14  149  		rcu_read_unlock_sched_notrace();			\
2fbb90db Steven Rostedt           2012-02-07  150  		postrcu;						\
97e1c18e Mathieu Desnoyers        2008-07-18  151  	} while (0)
97e1c18e Mathieu Desnoyers        2008-07-18  152  
7ece55a4 Josh Triplett            2012-09-04  153  #ifndef MODULE
7ece55a4 Josh Triplett            2012-09-04  154  #define __DECLARE_TRACE_RCU(name, proto, args, cond, data_proto, data_args)	\
7ece55a4 Josh Triplett            2012-09-04 @155  	static inline void trace_##name##_rcuidle(proto)		\
7ece55a4 Josh Triplett            2012-09-04  156  	{								\
7ece55a4 Josh Triplett            2012-09-04  157  		if (static_key_false(&__tracepoint_##name.key))		\
7ece55a4 Josh Triplett            2012-09-04  158  			__DO_TRACE(&__tracepoint_##name,		\
7ece55a4 Josh Triplett            2012-09-04  159  				TP_PROTO(data_proto),			\
7ece55a4 Josh Triplett            2012-09-04  160  				TP_ARGS(data_args),			\
7ece55a4 Josh Triplett            2012-09-04  161  				TP_CONDITION(cond),			\
7c9906ca Paul E. McKenney         2015-10-31  162  				rcu_irq_enter_irqson(),			\
7c9906ca Paul E. McKenney         2015-10-31  163  				rcu_irq_exit_irqson());			\
7ece55a4 Josh Triplett            2012-09-04  164  	}
7ece55a4 Josh Triplett            2012-09-04  165  #else
7ece55a4 Josh Triplett            2012-09-04  166  #define __DECLARE_TRACE_RCU(name, proto, args, cond, data_proto, data_args)
7ece55a4 Josh Triplett            2012-09-04  167  #endif
7ece55a4 Josh Triplett            2012-09-04  168  
97e1c18e Mathieu Desnoyers        2008-07-18  169  /*
97e1c18e Mathieu Desnoyers        2008-07-18  170   * Make sure the alignment of the structure in the __tracepoints section will
97e1c18e Mathieu Desnoyers        2008-07-18  171   * not add unwanted padding between the beginning of the section and the
97e1c18e Mathieu Desnoyers        2008-07-18  172   * structure. Force alignment to the same alignment as the section start.
3a630178 Dave Hansen              2014-08-07  173   *
3a630178 Dave Hansen              2014-08-07  174   * When lockdep is enabled, we make sure to always do the RCU portions of
a15920be Mathieu Desnoyers        2015-11-02  175   * the tracepoint code, regardless of whether tracing is on. However,
a15920be Mathieu Desnoyers        2015-11-02  176   * don't check if the condition is false, due to interaction with idle
a15920be Mathieu Desnoyers        2015-11-02  177   * instrumentation. This lets us find RCU issues triggered with tracepoints
a15920be Mathieu Desnoyers        2015-11-02  178   * even when this tracepoint is off. This code has no purpose other than
a15920be Mathieu Desnoyers        2015-11-02  179   * poking RCU a bit.
97e1c18e Mathieu Desnoyers        2008-07-18  180   */
287050d3 Steven Rostedt           2010-12-02  181  #define __DECLARE_TRACE(name, proto, args, cond, data_proto, data_args) \
7e066fb8 Mathieu Desnoyers        2008-11-14  182  	extern struct tracepoint __tracepoint_##name;			\
97e1c18e Mathieu Desnoyers        2008-07-18 @183  	static inline void trace_##name(proto)				\
97e1c18e Mathieu Desnoyers        2008-07-18  184  	{								\
c5905afb Ingo Molnar              2012-02-24  185  		if (static_key_false(&__tracepoint_##name.key))		\
97e1c18e Mathieu Desnoyers        2008-07-18  186  			__DO_TRACE(&__tracepoint_##name,		\
38516ab5 Steven Rostedt           2010-04-20  187  				TP_PROTO(data_proto),			\
287050d3 Steven Rostedt           2010-12-02  188  				TP_ARGS(data_args),			\
2fbb90db Steven Rostedt           2012-02-07  189  				TP_CONDITION(cond),,);			\
a05d59a5 Steven Rostedt (Red Hat  2015-02-06  190) 		if (IS_ENABLED(CONFIG_LOCKDEP) && (cond)) {		\
3a630178 Dave Hansen              2014-08-07  191  			rcu_read_lock_sched_notrace();			\
3a630178 Dave Hansen              2014-08-07  192  			rcu_dereference_sched(__tracepoint_##name.funcs);\
3a630178 Dave Hansen              2014-08-07  193  			rcu_read_unlock_sched_notrace();		\
3a630178 Dave Hansen              2014-08-07  194  		}							\
2fbb90db Steven Rostedt           2012-02-07  195  	}								\
7ece55a4 Josh Triplett            2012-09-04  196  	__DECLARE_TRACE_RCU(name, PARAMS(proto), PARAMS(args),		\
7ece55a4 Josh Triplett            2012-09-04  197  		PARAMS(cond), PARAMS(data_proto), PARAMS(data_args))	\
38516ab5 Steven Rostedt           2010-04-20  198  	static inline int						\
38516ab5 Steven Rostedt           2010-04-20 @199  	register_trace_##name(void (*probe)(data_proto), void *data)	\
97e1c18e Mathieu Desnoyers        2008-07-18  200  	{								\
de7b2973 Mathieu Desnoyers        2014-04-08  201  		return tracepoint_probe_register(&__tracepoint_##name,	\
de7b2973 Mathieu Desnoyers        2014-04-08  202  						(void *)probe, data);	\
97e1c18e Mathieu Desnoyers        2008-07-18  203  	}								\
38516ab5 Steven Rostedt           2010-04-20  204  	static inline int						\
7904b5c4 Steven Rostedt (Red Hat  2015-09-22 @205) 	register_trace_prio_##name(void (*probe)(data_proto), void *data,\
7904b5c4 Steven Rostedt (Red Hat  2015-09-22  206) 				   int prio)				\
7904b5c4 Steven Rostedt (Red Hat  2015-09-22  207) 	{								\
7904b5c4 Steven Rostedt (Red Hat  2015-09-22  208) 		return tracepoint_probe_register_prio(&__tracepoint_##name, \
7904b5c4 Steven Rostedt (Red Hat  2015-09-22  209) 					      (void *)probe, data, prio); \
7904b5c4 Steven Rostedt (Red Hat  2015-09-22  210) 	}								\
7904b5c4 Steven Rostedt (Red Hat  2015-09-22  211) 	static inline int						\
38516ab5 Steven Rostedt           2010-04-20 @212  	unregister_trace_##name(void (*probe)(data_proto), void *data)	\
97e1c18e Mathieu Desnoyers        2008-07-18  213  	{								\
de7b2973 Mathieu Desnoyers        2014-04-08  214  		return tracepoint_probe_unregister(&__tracepoint_##name,\
de7b2973 Mathieu Desnoyers        2014-04-08  215  						(void *)probe, data);	\
53da59aa Mathieu Desnoyers        2010-04-30  216  	}								\
38516ab5 Steven Rostedt           2010-04-20  217  	static inline void						\
38516ab5 Steven Rostedt           2010-04-20 @218  	check_trace_callback_type_##name(void (*cb)(data_proto))	\
53da59aa Mathieu Desnoyers        2010-04-30  219  	{								\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  220) 	}								\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  221) 	static inline bool						\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06 @222) 	trace_##name##_enabled(void)					\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  223) 	{								\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  224) 		return static_key_false(&__tracepoint_##name.key);	\
97e1c18e Mathieu Desnoyers        2008-07-18  225  	}
97e1c18e Mathieu Desnoyers        2008-07-18  226  
65498646 Mathieu Desnoyers        2011-01-26  227  /*
65498646 Mathieu Desnoyers        2011-01-26  228   * We have no guarantee that gcc and the linker won't up-align the tracepoint
65498646 Mathieu Desnoyers        2011-01-26  229   * structures, so we create an array of pointers that will be used for iteration
65498646 Mathieu Desnoyers        2011-01-26  230   * on the tracepoints.
65498646 Mathieu Desnoyers        2011-01-26  231   */
97419875 Josh Stone               2009-08-24  232  #define DEFINE_TRACE_FN(name, reg, unreg)				 \
7e066fb8 Mathieu Desnoyers        2008-11-14  233  	static const char __tpstrtab_##name[]				 \
7e066fb8 Mathieu Desnoyers        2008-11-14  234  	__attribute__((section("__tracepoints_strings"))) = #name;	 \
7e066fb8 Mathieu Desnoyers        2008-11-14 @235  	struct tracepoint __tracepoint_##name				 \
65498646 Mathieu Desnoyers        2011-01-26  236  	__attribute__((section("__tracepoints"))) =			 \
c5905afb Ingo Molnar              2012-02-24  237  		{ __tpstrtab_##name, STATIC_KEY_INIT_FALSE, reg, unreg, NULL };\
65498646 Mathieu Desnoyers        2011-01-26  238  	static struct tracepoint * const __tracepoint_ptr_##name __used	 \
65498646 Mathieu Desnoyers        2011-01-26  239  	__attribute__((section("__tracepoints_ptrs"))) =		 \
65498646 Mathieu Desnoyers        2011-01-26  240  		&__tracepoint_##name;
97419875 Josh Stone               2009-08-24  241  
97419875 Josh Stone               2009-08-24  242  #define DEFINE_TRACE(name)						\
97419875 Josh Stone               2009-08-24 @243  	DEFINE_TRACE_FN(name, NULL, NULL);
7e066fb8 Mathieu Desnoyers        2008-11-14  244  
7e066fb8 Mathieu Desnoyers        2008-11-14  245  #define EXPORT_TRACEPOINT_SYMBOL_GPL(name)				\
7e066fb8 Mathieu Desnoyers        2008-11-14  246  	EXPORT_SYMBOL_GPL(__tracepoint_##name)
7e066fb8 Mathieu Desnoyers        2008-11-14  247  #define EXPORT_TRACEPOINT_SYMBOL(name)					\
7e066fb8 Mathieu Desnoyers        2008-11-14  248  	EXPORT_SYMBOL(__tracepoint_##name)
7e066fb8 Mathieu Desnoyers        2008-11-14  249  
c63b7682 Tal Shorer               2015-08-01  250  #else /* !TRACEPOINTS_ENABLED */
287050d3 Steven Rostedt           2010-12-02  251  #define __DECLARE_TRACE(name, proto, args, cond, data_proto, data_args) \
97e1c18e Mathieu Desnoyers        2008-07-18  252  	static inline void trace_##name(proto)				\
97e1c18e Mathieu Desnoyers        2008-07-18  253  	{ }								\
2fbb90db Steven Rostedt           2012-02-07  254  	static inline void trace_##name##_rcuidle(proto)		\
2fbb90db Steven Rostedt           2012-02-07  255  	{ }								\
38516ab5 Steven Rostedt           2010-04-20  256  	static inline int						\
38516ab5 Steven Rostedt           2010-04-20  257  	register_trace_##name(void (*probe)(data_proto),		\
38516ab5 Steven Rostedt           2010-04-20  258  			      void *data)				\
97e1c18e Mathieu Desnoyers        2008-07-18  259  	{								\
97e1c18e Mathieu Desnoyers        2008-07-18  260  		return -ENOSYS;						\
97e1c18e Mathieu Desnoyers        2008-07-18  261  	}								\
38516ab5 Steven Rostedt           2010-04-20  262  	static inline int						\
38516ab5 Steven Rostedt           2010-04-20  263  	unregister_trace_##name(void (*probe)(data_proto),		\
38516ab5 Steven Rostedt           2010-04-20  264  				void *data)				\
c420970e Mathieu Desnoyers        2008-11-14  265  	{								\
c420970e Mathieu Desnoyers        2008-11-14  266  		return -ENOSYS;						\
53da59aa Mathieu Desnoyers        2010-04-30  267  	}								\
38516ab5 Steven Rostedt           2010-04-20  268  	static inline void check_trace_callback_type_##name(void (*cb)(data_proto)) \
53da59aa Mathieu Desnoyers        2010-04-30  269  	{								\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  270) 	}								\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  271) 	static inline bool						\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  272) 	trace_##name##_enabled(void)					\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  273) 	{								\
7c65bbc7 Steven Rostedt (Red Hat  2014-05-06  274) 		return false;						\
c420970e Mathieu Desnoyers        2008-11-14  275  	}
97e1c18e Mathieu Desnoyers        2008-07-18  276  
97419875 Josh Stone               2009-08-24  277  #define DEFINE_TRACE_FN(name, reg, unreg)
7e066fb8 Mathieu Desnoyers        2008-11-14  278  #define DEFINE_TRACE(name)
7e066fb8 Mathieu Desnoyers        2008-11-14  279  #define EXPORT_TRACEPOINT_SYMBOL_GPL(name)
7e066fb8 Mathieu Desnoyers        2008-11-14  280  #define EXPORT_TRACEPOINT_SYMBOL(name)
7e066fb8 Mathieu Desnoyers        2008-11-14  281  
c63b7682 Tal Shorer               2015-08-01  282  #endif /* TRACEPOINTS_ENABLED */
38516ab5 Steven Rostedt           2010-04-20  283  
3c49b52b Steven Rostedt           2014-07-25  284  #ifdef CONFIG_TRACING
3c49b52b Steven Rostedt           2014-07-25  285  /**
3c49b52b Steven Rostedt           2014-07-25  286   * tracepoint_string - register constant persistent string to trace system
3c49b52b Steven Rostedt           2014-07-25  287   * @str - a constant persistent string that will be referenced in tracepoints
3c49b52b Steven Rostedt           2014-07-25  288   *
3c49b52b Steven Rostedt           2014-07-25  289   * If constant strings are being used in tracepoints, it is faster and
3c49b52b Steven Rostedt           2014-07-25  290   * more efficient to just save the pointer to the string and reference
3c49b52b Steven Rostedt           2014-07-25  291   * that with a printf "%s" instead of saving the string in the ring buffer
3c49b52b Steven Rostedt           2014-07-25  292   * and wasting space and time.
3c49b52b Steven Rostedt           2014-07-25  293   *
3c49b52b Steven Rostedt           2014-07-25  294   * The problem with the above approach is that userspace tools that read
3c49b52b Steven Rostedt           2014-07-25  295   * the binary output of the trace buffers do not have access to the string.
3c49b52b Steven Rostedt           2014-07-25  296   * Instead they just show the address of the string which is not very
3c49b52b Steven Rostedt           2014-07-25  297   * useful to users.
3c49b52b Steven Rostedt           2014-07-25  298   *
3c49b52b Steven Rostedt           2014-07-25  299   * With tracepoint_string(), the string will be registered to the tracing
3c49b52b Steven Rostedt           2014-07-25  300   * system and exported to userspace via the debugfs/tracing/printk_formats
3c49b52b Steven Rostedt           2014-07-25  301   * file that maps the string address to the string text. This way userspace
3c49b52b Steven Rostedt           2014-07-25  302   * tools that read the binary buffers have a way to map the pointers to
3c49b52b Steven Rostedt           2014-07-25  303   * the ASCII strings they represent.
3c49b52b Steven Rostedt           2014-07-25  304   *
3c49b52b Steven Rostedt           2014-07-25  305   * The @str used must be a constant string and persistent as it would not
3c49b52b Steven Rostedt           2014-07-25  306   * make sense to show a string that no longer exists. But it is still fine
3c49b52b Steven Rostedt           2014-07-25  307   * to be used with modules, because when modules are unloaded, if they
3c49b52b Steven Rostedt           2014-07-25  308   * had tracepoints, the ring buffers are cleared too. As long as the string
3c49b52b Steven Rostedt           2014-07-25  309   * does not change during the life of the module, it is fine to use
3c49b52b Steven Rostedt           2014-07-25  310   * tracepoint_string() within a module.
3c49b52b Steven Rostedt           2014-07-25  311   */
3c49b52b Steven Rostedt           2014-07-25  312  #define tracepoint_string(str)						\
3c49b52b Steven Rostedt           2014-07-25  313  	({								\
3c49b52b Steven Rostedt           2014-07-25  314  		static const char *___tp_str __tracepoint_string = str; \
3c49b52b Steven Rostedt           2014-07-25  315  		___tp_str;						\
3c49b52b Steven Rostedt           2014-07-25  316  	})
3c49b52b Steven Rostedt           2014-07-25  317  #define __tracepoint_string	__attribute__((section("__tracepoint_str")))
3c49b52b Steven Rostedt           2014-07-25  318  #else
3c49b52b Steven Rostedt           2014-07-25  319  /*
3c49b52b Steven Rostedt           2014-07-25  320   * tracepoint_string() is used to save the string address for userspace
3c49b52b Steven Rostedt           2014-07-25  321   * tracing tools. When tracing isn't configured, there's no need to save
3c49b52b Steven Rostedt           2014-07-25  322   * anything.
3c49b52b Steven Rostedt           2014-07-25  323   */
3c49b52b Steven Rostedt           2014-07-25  324  # define tracepoint_string(str) str
3c49b52b Steven Rostedt           2014-07-25  325  # define __tracepoint_string
3c49b52b Steven Rostedt           2014-07-25  326  #endif
3c49b52b Steven Rostedt           2014-07-25  327  
38516ab5 Steven Rostedt           2010-04-20  328  /*
38516ab5 Steven Rostedt           2010-04-20  329   * The need for the DECLARE_TRACE_NOARGS() is to handle the prototype
38516ab5 Steven Rostedt           2010-04-20  330   * (void). "void" is a special value in a function prototype and can
38516ab5 Steven Rostedt           2010-04-20  331   * not be combined with other arguments. Since the DECLARE_TRACE()
38516ab5 Steven Rostedt           2010-04-20  332   * macro adds a data element at the beginning of the prototype,
38516ab5 Steven Rostedt           2010-04-20  333   * we need a way to differentiate "(void *data, proto)" from
38516ab5 Steven Rostedt           2010-04-20  334   * "(void *data, void)". The second prototype is invalid.
38516ab5 Steven Rostedt           2010-04-20  335   *
38516ab5 Steven Rostedt           2010-04-20  336   * DECLARE_TRACE_NOARGS() passes "void" as the tracepoint prototype
38516ab5 Steven Rostedt           2010-04-20  337   * and "void *__data" as the callback prototype.
38516ab5 Steven Rostedt           2010-04-20  338   *
38516ab5 Steven Rostedt           2010-04-20  339   * DECLARE_TRACE() passes "proto" as the tracepoint protoype and
38516ab5 Steven Rostedt           2010-04-20  340   * "void *__data, proto" as the callback prototype.
38516ab5 Steven Rostedt           2010-04-20  341   */
38516ab5 Steven Rostedt           2010-04-20  342  #define DECLARE_TRACE_NOARGS(name)					\
dc17147d Steven Rostedt (Red Hat  2016-03-09  343) 	__DECLARE_TRACE(name, void, ,					\
dc17147d Steven Rostedt (Red Hat  2016-03-09  344) 			cpu_online(raw_smp_processor_id()),		\
dc17147d Steven Rostedt (Red Hat  2016-03-09  345) 			void *__data, __data)
38516ab5 Steven Rostedt           2010-04-20  346  
38516ab5 Steven Rostedt           2010-04-20  347  #define DECLARE_TRACE(name, proto, args)				\
dc17147d Steven Rostedt (Red Hat  2016-03-09 @348) 	__DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),		\
dc17147d Steven Rostedt (Red Hat  2016-03-09  349) 			cpu_online(raw_smp_processor_id()),		\
287050d3 Steven Rostedt           2010-12-02  350  			PARAMS(void *__data, proto),			\
287050d3 Steven Rostedt           2010-12-02  351  			PARAMS(__data, args))

:::::: The code at line 183 was first introduced by commit
:::::: 97e1c18e8d17bd87e1e383b2e9d9fc740332c8e2 tracing: Kernel Tracepoints

:::::: TO: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
:::::: CC: Ingo Molnar <mingo@elte.hu>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--h31gzZEtNLTqOjlF
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--h31gzZEtNLTqOjlF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
