Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 83E26828DF
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 05:28:47 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id uo6so21646916pac.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:28:47 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id n28si16114748pfj.101.2016.01.28.02.28.46
        for <linux-mm@kvack.org>;
        Thu, 28 Jan 2016 02:28:46 -0800 (PST)
Date: Thu, 28 Jan 2016 18:28:11 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master] 888c8375131656144c1605071eab2eb6ac49abc3
 BUILD DONE
Message-ID: <56a9ed3b.aWLlru/OacuRp1fI%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
888c8375131656144c1605071eab2eb6ac49abc3  Add linux-next specific files for 20160128

arch/frv/include/asm/page.h:68:27: error: 'READ_IMPLIES_EXEC' undeclared (first use in this function)
arch/mn10300/include/asm/page.h:124:27: error: 'READ_IMPLIES_EXEC' undeclared (first use in this function)
crypto/twofish_common.c:700:1: warning: the frame size of 4700 bytes is larger than 1024 bytes [-Wframe-larger-than=]
crypto/twofish_common.c:700:1: warning: the frame size of 4728 bytes is larger than 1024 bytes [-Wframe-larger-than=]
fs/ocfs2/file.c:2198:1: warning: label 'relock' defined but not used [-Wunused-label]
include/linux/completion.h:76:2: note: in expansion of macro 'init_waitqueue_head'
include/linux/llist.h:193:2: error: implicit declaration of function 'xchg' [-Werror=implicit-function-declaration]
include/linux/llist.h:193:2: warning: return makes pointer from integer without a cast
include/linux/lockdep.h:280:13: warning: conflicting types for 'lockdep_init_map'
include/linux/lockdep.h:333:13: warning: conflicting types for 'lock_acquire'
include/linux/lockdep.h:337:13: warning: conflicting types for 'lock_release'
include/linux/lockdep.h:545:6: warning: conflicting types for 'lockdep_rcu_suspicious'
include/linux/memory_hotplug.h:54:2: note: in expansion of macro 'spin_lock_init'
include/linux/memory_hotplug.h:81:2: note: in expansion of macro 'seqlock_init'
include/linux/mm.h:1602:2: note: in expansion of macro 'spin_lock_init'
include/linux/mm.h:200:32: error: 'VM_DATA_DEFAULT_FLAGS' undeclared (first use in this function)
include/linux/mm.h:200:32: note: in expansion of macro 'VM_DATA_DEFAULT_FLAGS'
include/linux/mm.h:206:40: note: in expansion of macro 'VM_STACK_DEFAULT_FLAGS'
include/linux/ratelimit.h:37:2: note: in expansion of macro 'raw_spin_lock_init'
include/linux/rcupdate.h:490:2: error: implicit declaration of function 'lock_acquire' [-Werror=implicit-function-declaration]
include/linux/rcupdate.h:495:2: error: implicit declaration of function 'lock_release' [-Werror=implicit-function-declaration]
include/linux/rcupdate.h:572:2: error: implicit declaration of function 'lockdep_rcu_suspicious' [-Werror=implicit-function-declaration]
include/linux/rcupdate.h:572:2: error: implicit declaration of function 'lock_is_held' [-Werror=implicit-function-declaration]
include/linux/rcupdate.h:572:2: note: in expansion of macro 'RCU_LOCKDEP_WARN'
include/linux/rwlock_api_smp.h:121:3: error: implicit declaration of function 'rwlock_acquire_read' [-Werror=implicit-function-declaration]
include/linux/rwlock_api_smp.h:132:3: error: implicit declaration of function 'rwlock_acquire' [-Werror=implicit-function-declaration]
include/linux/rwlock_api_smp.h:160:2: error: implicit declaration of function 'LOCK_CONTENDED_FLAGS' [-Werror=implicit-function-declaration]
include/linux/rwlock_api_smp.h:161:9: error: 'do_raw_read_lock_flags' undeclared (first use in this function)
include/linux/rwlock_api_smp.h:188:9: error: 'do_raw_write_lock_flags' undeclared (first use in this function)
include/linux/rwlock_api_smp.h:218:2: error: implicit declaration of function 'rwlock_release' [-Werror=implicit-function-declaration]
include/linux/rwlock.h:19:15: warning: 'struct lock_class_key' declared inside parameter list
include/linux/rwlock_types.h:21:21: error: field 'dep_map' has incomplete type
include/linux/semaphore.h:35:17: error: field name not in record or union initializer
include/linux/seqlock.h:374:2: error: implicit declaration of function 'seqcount_acquire' [-Werror=implicit-function-declaration]
include/linux/seqlock.h:418:3: note: in expansion of macro 'seqcount_init'
include/linux/seqlock.h:419:3: note: in expansion of macro 'spin_lock_init'
include/linux/seqlock.h:50:21: error: field 'dep_map' has incomplete type
include/linux/seqlock.h:55:15: warning: 'struct lock_class_key' declared inside parameter list
include/linux/seqlock.h:60:2: error: implicit declaration of function 'lockdep_init_map' [-Werror=implicit-function-declaration]
include/linux/seqlock.h:71:3: warning: passing argument 3 of '__seqcount_init' from incompatible pointer type
include/linux/seqlock.h:80:2: error: implicit declaration of function 'seqcount_acquire_read' [-Werror=implicit-function-declaration]
include/linux/seqlock.h:81:2: error: implicit declaration of function 'seqcount_release' [-Werror=implicit-function-declaration]
include/linux/spinlock_api_smp.h:119:2: error: implicit declaration of function 'LOCK_CONTENDED' [-Werror=implicit-function-declaration]
include/linux/spinlock_api_smp.h:152:2: error: implicit declaration of function 'spin_release' [-Werror=implicit-function-declaration]
include/linux/spinlock_api_smp.h:92:3: error: implicit declaration of function 'spin_acquire' [-Werror=implicit-function-declaration]
include/linux/spinlock.h:297:2: note: in expansion of macro 'raw_spin_lock_init'
include/linux/spinlock.h:94:15: warning: its scope is only this definition or declaration, which is probably not what you want
include/linux/spinlock.h:94:15: warning: 'struct lock_class_key' declared inside parameter list
include/linux/spinlock.h:99:2: warning: passing argument 3 of '__raw_spin_lock_init' from incompatible pointer type
include/linux/spinlock_types.h:30:21: error: field 'dep_map' has incomplete type
include/linux/wait.h:1217:2: error: implicit declaration of function 'atomic_read' [-Werror=implicit-function-declaration]
include/linux/wait.h:72:82: warning: 'struct lock_class_key' declared inside parameter list
include/linux/wait.h:76:32: error: storage size of '__key' isn't known
lib/../mm/internal.h:227:19: error: 'READ_IMPLIES_EXEC' undeclared (first use in this function)
lib/../mm/internal.h:227:19: note: in expansion of macro 'VM_STACK_FLAGS'
mm/internal.h:226:19: error: 'READ_IMPLIES_EXEC' undeclared (first use in this function)
mm/internal.h:226:19: note: in expansion of macro 'VM_STACK_FLAGS'
mm/slab.c:1882: warning: Excess function parameter 'align' description in 'calculate_slab_order'
mm/slab.h:316:7: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
mm/slab.h:316:9: error: implicit declaration of function 'virt_to_head_page' [-Werror=implicit-function-declaration]

Error ids grouped by kconfigs:

recent_errors
a??a??a?? blackfin-TCM-BF537_defconfig
a??A A  a??a??a?? lib-..-mm-internal.h:error:READ_IMPLIES_EXEC-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? mm-internal.h:error:READ_IMPLIES_EXEC-undeclared-(first-use-in-this-function)
a??a??a?? frv-defconfig
a??A A  a??a??a?? arch-frv-include-asm-page.h:error:READ_IMPLIES_EXEC-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-mm.h:note:in-expansion-of-macro-VM_DATA_DEFAULT_FLAGS
a??A A  a??a??a?? include-linux-mm.h:note:in-expansion-of-macro-VM_STACK_DEFAULT_FLAGS
a??A A  a??a??a?? lib-..-mm-internal.h:note:in-expansion-of-macro-VM_STACK_FLAGS
a??A A  a??a??a?? mm-internal.h:note:in-expansion-of-macro-VM_STACK_FLAGS
a??a??a?? i386-allmodconfig
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? i386-allnoconfig
a??A A  a??a??a?? mm-slab.c:warning:Excess-function-parameter-align-description-in-calculate_slab_order
a??a??a?? i386-randconfig-a0-01271607
a??A A  a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
a??A A  a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? i386-randconfig-c0-01281628
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? i386-randconfig-h1-01281709
a??A A  a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
a??A A  a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? i386-randconfig-sb0-01281521
a??A A  a??a??a?? crypto-twofish_common.c:warning:the-frame-size-of-bytes-is-larger-than-bytes
a??a??a?? i386-randconfig-sb0-01281659
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? i386-randconfig-x0-01281526
a??A A  a??a??a?? crypto-twofish_common.c:warning:the-frame-size-of-bytes-is-larger-than-bytes
a??a??a?? microblaze-nommu_defconfig
a??A A  a??a??a?? include-linux-mm.h:error:VM_DATA_DEFAULT_FLAGS-undeclared-(first-use-in-this-function)
a??a??a?? mn10300-asb2364_defconfig
a??A A  a??a??a?? arch-mn10300-include-asm-page.h:error:READ_IMPLIES_EXEC-undeclared-(first-use-in-this-function)
a??a??a?? s390-allyesconfig
a??A A  a??a??a?? include-linux-completion.h:note:in-expansion-of-macro-init_waitqueue_head
a??A A  a??a??a?? include-linux-llist.h:error:implicit-declaration-of-function-xchg
a??A A  a??a??a?? include-linux-llist.h:warning:return-makes-pointer-from-integer-without-a-cast
a??A A  a??a??a?? include-linux-lockdep.h:warning:conflicting-types-for-lock_acquire
a??A A  a??a??a?? include-linux-lockdep.h:warning:conflicting-types-for-lockdep_init_map
a??A A  a??a??a?? include-linux-lockdep.h:warning:conflicting-types-for-lockdep_rcu_suspicious
a??A A  a??a??a?? include-linux-lockdep.h:warning:conflicting-types-for-lock_release
a??A A  a??a??a?? include-linux-memory_hotplug.h:note:in-expansion-of-macro-seqlock_init
a??A A  a??a??a?? include-linux-memory_hotplug.h:note:in-expansion-of-macro-spin_lock_init
a??A A  a??a??a?? include-linux-mm.h:note:in-expansion-of-macro-spin_lock_init
a??A A  a??a??a?? include-linux-ratelimit.h:note:in-expansion-of-macro-raw_spin_lock_init
a??A A  a??a??a?? include-linux-rcupdate.h:error:implicit-declaration-of-function-lock_acquire
a??A A  a??a??a?? include-linux-rcupdate.h:error:implicit-declaration-of-function-lockdep_rcu_suspicious
a??A A  a??a??a?? include-linux-rcupdate.h:error:implicit-declaration-of-function-lock_is_held
a??A A  a??a??a?? include-linux-rcupdate.h:error:implicit-declaration-of-function-lock_release
a??A A  a??a??a?? include-linux-rcupdate.h:note:in-expansion-of-macro-RCU_LOCKDEP_WARN
a??A A  a??a??a?? include-linux-rwlock_api_smp.h:error:do_raw_read_lock_flags-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-rwlock_api_smp.h:error:do_raw_write_lock_flags-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-rwlock_api_smp.h:error:implicit-declaration-of-function-LOCK_CONTENDED_FLAGS
a??A A  a??a??a?? include-linux-rwlock_api_smp.h:error:implicit-declaration-of-function-rwlock_acquire
a??A A  a??a??a?? include-linux-rwlock_api_smp.h:error:implicit-declaration-of-function-rwlock_acquire_read
a??A A  a??a??a?? include-linux-rwlock_api_smp.h:error:implicit-declaration-of-function-rwlock_release
a??A A  a??a??a?? include-linux-rwlock.h:warning:struct-lock_class_key-declared-inside-parameter-list
a??A A  a??a??a?? include-linux-rwlock_types.h:error:field-dep_map-has-incomplete-type
a??A A  a??a??a?? include-linux-semaphore.h:error:field-name-not-in-record-or-union-initializer
a??A A  a??a??a?? include-linux-seqlock.h:error:field-dep_map-has-incomplete-type
a??A A  a??a??a?? include-linux-seqlock.h:error:implicit-declaration-of-function-lockdep_init_map
a??A A  a??a??a?? include-linux-seqlock.h:error:implicit-declaration-of-function-seqcount_acquire
a??A A  a??a??a?? include-linux-seqlock.h:error:implicit-declaration-of-function-seqcount_acquire_read
a??A A  a??a??a?? include-linux-seqlock.h:error:implicit-declaration-of-function-seqcount_release
a??A A  a??a??a?? include-linux-seqlock.h:note:in-expansion-of-macro-seqcount_init
a??A A  a??a??a?? include-linux-seqlock.h:note:in-expansion-of-macro-spin_lock_init
a??A A  a??a??a?? include-linux-seqlock.h:warning:passing-argument-of-__seqcount_init-from-incompatible-pointer-type
a??A A  a??a??a?? include-linux-seqlock.h:warning:struct-lock_class_key-declared-inside-parameter-list
a??A A  a??a??a?? include-linux-spinlock_api_smp.h:error:implicit-declaration-of-function-LOCK_CONTENDED
a??A A  a??a??a?? include-linux-spinlock_api_smp.h:error:implicit-declaration-of-function-spin_acquire
a??A A  a??a??a?? include-linux-spinlock_api_smp.h:error:implicit-declaration-of-function-spin_release
a??A A  a??a??a?? include-linux-spinlock.h:note:in-expansion-of-macro-raw_spin_lock_init
a??A A  a??a??a?? include-linux-spinlock.h:warning:its-scope-is-only-this-definition-or-declaration-which-is-probably-not-what-you-want
a??A A  a??a??a?? include-linux-spinlock.h:warning:passing-argument-of-__raw_spin_lock_init-from-incompatible-pointer-type
a??A A  a??a??a?? include-linux-spinlock.h:warning:struct-lock_class_key-declared-inside-parameter-list
a??A A  a??a??a?? include-linux-spinlock_types.h:error:field-dep_map-has-incomplete-type
a??A A  a??a??a?? include-linux-wait.h:error:implicit-declaration-of-function-atomic_read
a??A A  a??a??a?? include-linux-wait.h:error:storage-size-of-__key-isn-t-known
a??A A  a??a??a?? include-linux-wait.h:warning:struct-lock_class_key-declared-inside-parameter-list
a??a??a?? x86_64-allmodconfig
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-allyesdebian
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-b0-01281432
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-b0-01281545
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-b0-01281614
a??A A  a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
a??A A  a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? x86_64-randconfig-h0-01281604
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-n0-01281453
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-n0-01281615
a??A A  a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
a??A A  a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? x86_64-randconfig-n0-01281657
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-r0-01281613
a??A A  a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
a??A A  a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? x86_64-randconfig-s0-01281506
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-s0-01281631
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-s1-01281506
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-s1-01281631
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-s2-01281534
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-s2-01281658
a??A A  a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
a??A A  a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? x86_64-randconfig-s3-01281725
a??A A  a??a??a?? fs-ocfs2-file.c:warning:label-relock-defined-but-not-used
a??a??a?? x86_64-randconfig-s4-01281656
a??A A  a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
a??A A  a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? x86_64-randconfig-s4-01281725
    a??a??a?? mm-slab.h:error:implicit-declaration-of-function-virt_to_head_page
    a??a??a?? mm-slab.h:warning:assignment-makes-pointer-from-integer-without-a-cast

elapsed time: 227m

configs tested: 200

m32r                   mappi2.vdec2_defconfig
i386                   randconfig-a0-01271607
x86_64                 randconfig-a0-01281534
x86_64                 randconfig-a0-01281639
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
cris                 etrax-100lx_v2_defconfig
blackfin                  TCM-BF537_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin                BF526-EZBRD_defconfig
powerpc                      obs600_defconfig
arm                           stm32_defconfig
i386                   randconfig-c0-01281446
i386                   randconfig-c0-01281553
i386                   randconfig-c0-01281628
arm                                    sa1100
arm                          prima2_defconfig
arm                         at91_dt_defconfig
arm                               allnoconfig
arm                                   samsung
arm                       spear13xx_defconfig
arm                                  iop-adma
arm                       imx_v6_v7_defconfig
arm                          marzen_defconfig
arm                                  at_hdmac
arm                                    ep93xx
arm                                        sh
mips                        msp71xx_defconfig
arm                           h5000_defconfig
arm                          pcm027_defconfig
x86_64                 randconfig-v0-01281445
x86_64                 randconfig-v0-01281545
x86_64                 randconfig-v0-01281658
parisc                        c3000_defconfig
parisc                         b180_defconfig
parisc                              defconfig
alpha                               defconfig
parisc                            allnoconfig
powerpc                     redwood_defconfig
powerpc                        cell_defconfig
mips                       bmips_be_defconfig
arm                     davinci_all_defconfig
x86_64                           alldefconfig
m32r                    mappi.nommu_defconfig
powerpc                      acadia_defconfig
sh                           se7721_defconfig
x86_64               randconfig-x015-01270835
x86_64               randconfig-x011-01270835
x86_64               randconfig-x016-01270835
x86_64               randconfig-x012-01270835
x86_64               randconfig-x019-01270835
x86_64               randconfig-x018-01270835
x86_64               randconfig-x017-01270835
x86_64               randconfig-x010-01270835
x86_64               randconfig-x014-01270835
x86_64               randconfig-x013-01270835
i386                     randconfig-s0-201604
i386                     randconfig-s1-201604
x86_64                 randconfig-s2-01281506
x86_64                 randconfig-s0-01281506
x86_64                 randconfig-s1-01281506
x86_64                 randconfig-s0-01281534
x86_64                 randconfig-s1-01281534
x86_64                 randconfig-s2-01281534
x86_64                 randconfig-s2-01281631
x86_64                 randconfig-s0-01281631
x86_64                 randconfig-s1-01281631
x86_64                 randconfig-s1-01281658
x86_64                 randconfig-s0-01281658
x86_64                 randconfig-s2-01281658
x86_64                 randconfig-s2-01281726
x86_64                 randconfig-s0-01281726
x86_64                 randconfig-s1-01281726
x86_64                 randconfig-s5-01281440
x86_64                 randconfig-s3-01281440
x86_64                 randconfig-s4-01281440
x86_64                 randconfig-s4-01281519
x86_64                 randconfig-s5-01281519
x86_64                 randconfig-s3-01281519
x86_64                 randconfig-s3-01281547
x86_64                 randconfig-s5-01281547
x86_64                 randconfig-s4-01281547
x86_64                 randconfig-s5-01281617
x86_64                 randconfig-s3-01281617
x86_64                 randconfig-s4-01281617
x86_64                 randconfig-s4-01281656
x86_64                 randconfig-s3-01281656
x86_64                 randconfig-s5-01281656
x86_64                 randconfig-s4-01281725
x86_64                 randconfig-s3-01281725
x86_64                 randconfig-s5-01281725
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
avr32                      atngw100_defconfig
avr32                     atstk1006_defconfig
tile                         tilegx_defconfig
i386                             allmodconfig
powerpc                     sbc8548_defconfig
openrisc                            defconfig
avr32                            alldefconfig
powerpc                      ppc40x_defconfig
powerpc                             defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
x86_64                 randconfig-i0-01270829
i386                   randconfig-b0-01281441
i386                   randconfig-b0-01281549
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
sh                          sdk7786_defconfig
powerpc                          g5_defconfig
frv                                 defconfig
arm                          exynos_defconfig
m68k                          atari_defconfig
powerpc                     kmp204x_defconfig
blackfin                BF533-STAMP_defconfig
arm                          collie_defconfig
i386                   randconfig-i1-01281320
i386                   randconfig-i0-01281320
x86_64                 randconfig-b0-01281432
x86_64                 randconfig-b0-01281518
x86_64                 randconfig-b0-01281545
x86_64                 randconfig-b0-01281614
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
powerpc                     akebono_defconfig
powerpc                 mpc837x_rdb_defconfig
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-n0-201604
i386                   randconfig-h0-01281435
i386                   randconfig-h1-01281435
i386                   randconfig-h1-01281709
i386                   randconfig-h0-01281709
x86_64                 randconfig-h0-01281604
mips                malta_kvm_guest_defconfig
m32r                      mappi.smp_defconfig
powerpc64                        alldefconfig
x86_64                 randconfig-n0-01281453
x86_64                 randconfig-n0-01281541
x86_64                 randconfig-n0-01281615
x86_64                 randconfig-n0-01281657
powerpc                 xes_mpc85xx_defconfig
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
i386                  randconfig-sb0-01281521
i386                  randconfig-sb0-01281659
x86_64                           allmodconfig
x86_64               randconfig-x004-01270829
x86_64               randconfig-x003-01270829
x86_64               randconfig-x005-01270829
x86_64               randconfig-x000-01270829
x86_64               randconfig-x001-01270829
x86_64               randconfig-x006-01270829
x86_64               randconfig-x009-01270829
x86_64               randconfig-x002-01270829
x86_64               randconfig-x007-01270829
x86_64               randconfig-x008-01270829
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
x86_64                                    lkp
x86_64                                   rhel
i386                     randconfig-r0-201604
x86_64                 randconfig-r0-01281613
m68k                        mvme16x_defconfig
arm                     eseries_pxa_defconfig
arm                           sama5_defconfig
i386                 randconfig-x008-01261041
i386                 randconfig-x005-01261041
i386                 randconfig-x004-01261041
i386                 randconfig-x001-01261041
i386                 randconfig-x006-01261041
i386                 randconfig-x009-01261041
i386                 randconfig-x003-01261041
i386                 randconfig-x000-01261041
i386                 randconfig-x002-01261041
i386                 randconfig-x007-01261041
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
mips                                   jz4740
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
i386                   randconfig-x0-01281526

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
