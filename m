Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 59F7C6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 04:29:24 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so143161137wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:29:24 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id gg9si47487971wjb.115.2016.02.16.01.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 01:29:22 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id c200so150306011wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:29:21 -0800 (PST)
Date: Tue, 16 Feb 2016 10:29:17 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/33] x86: Memory Protection Keys (v10)
Message-ID: <20160216092917.GA7334@gmail.com>
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, jack@suse.cz, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, vbabka@suse.cz


* Dave Hansen <dave@sr71.net> wrote:

>  81 files changed, 1393 insertions(+), 233 deletions(-)

The MIPS defconfig cross-build failed for me - log attached below.

Thanks,

	Ingo

===============>
  CC      security/keys/request_key_auth.o
In file included from /home/mingo/tip/arch/mips/include/asm/termios.h:12:0,
                 from /home/mingo/tip/include/uapi/linux/termios.h:5,
                 from /home/mingo/tip/include/linux/tty.h:6,
                 from /home/mingo/tip/kernel/signal.c:18:
/home/mingo/tip/kernel/signal.c: In function 'copy_siginfo_to_user':
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:441:15: note: in definition of macro '__put_user_nocheck'
  __typeof__(*(ptr)) __pu_val;     \
               ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'const struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:444:14: note: in definition of macro '__put_user_nocheck'
  __pu_val = (x);       \
              ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:28: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                            ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:430:10: note: in definition of macro '__put_user_common'
  switch (size) {       \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:446:3: note: in expansion of macro '__put_kernel_common'
   __put_kernel_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:241:51: note: in definition of macro '__m'
 #define __m(x) (*(struct __large_struct __user *)(x))
                                                   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:431:10: note: in expansion of macro '__put_data_asm'
  case 1: __put_data_asm(user_sb, ptr); break;   \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:384:40: note: in expansion of macro '__put_user_common'
 #define __put_kernel_common(ptr, size) __put_user_common(ptr, size)
                                        ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:446:3: note: in expansion of macro '__put_kernel_common'
   __put_kernel_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:241:51: note: in definition of macro '__m'
 #define __m(x) (*(struct __large_struct __user *)(x))
                                                   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:432:10: note: in expansion of macro '__put_data_asm'
  case 2: __put_data_asm(user_sh, ptr); break;   \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:384:40: note: in expansion of macro '__put_user_common'
 #define __put_kernel_common(ptr, size) __put_user_common(ptr, size)
                                        ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:446:3: note: in expansion of macro '__put_kernel_common'
   __put_kernel_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:241:51: note: in definition of macro '__m'
 #define __m(x) (*(struct __large_struct __user *)(x))
                                                   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:433:10: note: in expansion of macro '__put_data_asm'
  case 4: __put_data_asm(user_sw, ptr); break;   \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:384:40: note: in expansion of macro '__put_user_common'
 #define __put_kernel_common(ptr, size) __put_user_common(ptr, size)
                                        ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:446:3: note: in expansion of macro '__put_kernel_common'
   __put_kernel_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:505:34: note: in definition of macro '__put_data_asm_ll32'
  : "0" (0), "r" (__pu_val), "r" (ptr),    \
                                  ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:434:10: note: in expansion of macro '__PUT_DW'
  case 8: __PUT_DW(user_sd, ptr); break;    \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:384:40: note: in expansion of macro '__put_user_common'
 #define __put_kernel_common(ptr, size) __put_user_common(ptr, size)
                                        ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:446:3: note: in expansion of macro '__put_kernel_common'
   __put_kernel_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:430:10: note: in definition of macro '__put_user_common'
  switch (size) {       \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:241:51: note: in definition of macro '__m'
 #define __m(x) (*(struct __large_struct __user *)(x))
                                                   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:431:10: note: in expansion of macro '__put_data_asm'
  case 1: __put_data_asm(user_sb, ptr); break;   \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:449:3: note: in expansion of macro '__put_user_common'
   __put_user_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
  CC      security/keys/user_defined.o
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:241:51: note: in definition of macro '__m'
 #define __m(x) (*(struct __large_struct __user *)(x))
                                                   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:432:10: note: in expansion of macro '__put_data_asm'
  case 2: __put_data_asm(user_sh, ptr); break;   \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:449:3: note: in expansion of macro '__put_user_common'
   __put_user_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:241:51: note: in definition of macro '__m'
 #define __m(x) (*(struct __large_struct __user *)(x))
                                                   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:433:10: note: in expansion of macro '__put_data_asm'
  case 4: __put_data_asm(user_sw, ptr); break;   \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:449:3: note: in expansion of macro '__put_user_common'
   __put_user_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
/home/mingo/tip/include/uapi/asm-generic/siginfo.h:145:37: error: 'struct <anonymous>' has no member named '_pkey'
 #define si_pkey  _sifields._sigfault._pkey
                                     ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:505:34: note: in definition of macro '__put_data_asm_ll32'
  : "0" (0), "r" (__pu_val), "r" (ptr),    \
                                  ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:434:10: note: in expansion of macro '__PUT_DW'
  case 8: __PUT_DW(user_sd, ptr); break;    \
          ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:449:3: note: in expansion of macro '__put_user_common'
   __put_user_common(ptr, size);    \
   ^
/home/mingo/tip/arch/mips/include/asm/uaccess.h:214:2: note: in expansion of macro '__put_user_nocheck'
  __put_user_nocheck((x), (ptr), sizeof(*(ptr)))
  ^
/home/mingo/tip/kernel/signal.c:2714:11: note: in expansion of macro '__put_user'
    err |= __put_user(from->si_pkey, &to->si_pkey);
           ^
/home/mingo/tip/kernel/signal.c:2714:42: note: in expansion of macro 'si_pkey'
    err |= __put_user(from->si_pkey, &to->si_pkey);
                                          ^
  CC      mm/mmzone.o
  CC      mm/vmstat.o
  UPD     kernel/config_data.h
  CC      mm/backing-dev.o
  CC      security/keys/proc.o
  CC      fs/open.o
  CC      fs/read_write.o
  CC      mm/mm_init.o
  CC      fs/file_table.o
  CC      security/keys/sysctl.o
  LD      arch/mips/sgi-ip22/built-in.o
  CC      mm/mmu_context.o
  CC      fs/super.o
  CC      fs/char_dev.o
  CC      fs/stat.o
/home/mingo/tip/scripts/Makefile.build:258: recipe for target 'kernel/signal.o' failed
make[2]: *** [kernel/signal.o] Error 1
make[2]: *** Waiting for unfinished jobs....
  CC      mm/percpu.o
  CC      fs/exec.o
  CC      kernel/locking/percpu-rwsem.o
  CC      kernel/locking/rwsem.o
  CC      fs/pipe.o
  CC      mm/slab_common.o
  LD      arch/mips/vdso/built-in.o
  CC      mm/compaction.o
  CC      kernel/locking/rwsem-spinlock.o
  CC      kernel/locking/rtmutex.o
  CC      kernel/irq/autoprobe.o
  CC      fs/namei.o
  CC      fs/fcntl.o
  CC      kernel/irq/irqdomain.o
  CC      kernel/rcu/sync.o
  CC      kernel/rcu/srcu.o
  CC      kernel/rcu/tiny.o
  CC      kernel/time/posix-timers.o
  CC      mm/vmacache.o
  CC      kernel/sched/idle_task.o
  CC      kernel/sched/fair.o
  CC      kernel/sched/rt.o
  CC      fs/ioctl.o
  CC      mm/interval_tree.o
  CC      kernel/sched/deadline.o
  CC      fs/readdir.o
  CC      mm/workingset.o
  CC      mm/list_lru.o
  CC      mm/debug.o
  CC      crypto/api.o
  CC      crypto/cipher.o
  CC      mm/gup.o
  CC      mm/highmem.o
  CC      kernel/irq/proc.o
  CC      kernel/sched/stop_task.o
  CC      kernel/sched/wait.o
  CC      mm/memory.o
  CC      kernel/sched/completion.o
  CC      kernel/sched/idle.o
  CC      mm/mincore.o
  CC      fs/select.o
  CC      kernel/sched/debug.o
  CC      kernel/time/posix-cpu-timers.o
  CC      fs/dcache.o
  CC      fs/inode.o
  CC      kernel/time/timekeeping.o
  CC      fs/attr.o
  CC      mm/mmap.o
  CC      mm/mprotect.o
  CC      kernel/time/ntp.o
  CC      mm/mlock.o
  CC      crypto/compress.o
  CC      fs/file.o
  CC      fs/bad_inode.o
  CC      mm/mremap.o
  CC      kernel/time/clocksource.o
  CC      fs/filesystems.o
  CC      mm/msync.o
  CC      mm/rmap.o
  LD      kernel/power/built-in.o
  CC      block/bio.o
  CC      kernel/time/jiffies.o
  CC      mm/vmalloc.o
  CC      kernel/time/timer_list.o
  CC      crypto/memneq.o
  CC      fs/namespace.o
  CC      mm/pagewalk.o
  CC      block/blk-core.o
  CC      crypto/crypto_wq.o
  CC      block/elevator.o
  CC      fs/seq_file.o
  LD      sound/built-in.o
  CC      kernel/time/timeconv.o
  CC      kernel/time/timecounter.o
  CC      mm/pgtable-generic.o
  CC      crypto/algapi.o
  CC      crypto/scatterwalk.o
  CC      block/blk-tag.o
  CC      kernel/time/posix-clock.o
  CC      fs/xattr.o
  LD      init/mounts.o
  CC      kernel/time/clockevents.o
  LD      ipc/built-in.o
  LD      init/built-in.o
  CC      kernel/time/alarmtimer.o
  CC      fs/libfs.o
  CC      kernel/time/tick-common.o
  CC      mm/process_vm_access.o
  CC      crypto/proc.o
  CC      mm/bootmem.o
  CC      mm/init-mm.o
  CC      block/blk-sysfs.o
  CC      fs/fs-writeback.o
  CC      kernel/time/sched_clock.o
  CC      block/blk-flush.o
  CC      fs/pnode.o
  LD      firmware/built-in.o
  CC      block/blk-settings.o
  CC      crypto/aead.o
  CC      block/blk-ioc.o
  CC      block/blk-map.o
  CC      fs/splice.o
  CC      kernel/time/tick-oneshot.o
  CC      mm/fadvise.o
  CC      mm/madvise.o
  CC      block/blk-exec.o
  CC      fs/sync.o
  LD      kernel/bpf/built-in.o
  CC      kernel/time/tick-sched.o
  CC      crypto/ablkcipher.o
  CC      crypto/blkcipher.o
  CC      fs/utimes.o
  CC      crypto/skcipher.o
  CC      fs/stack.o
  CC      fs/fs_struct.o
  LD      arch/mips/power/built-in.o
  CC      block/blk-merge.o
  LD      kernel/locking/built-in.o
  CC      mm/page_io.o
  CC      fs/statfs.o
  LD      security/keys/built-in.o
  CC      mm/memblock.o
  LD      security/built-in.o
  CC      fs/nsfs.o
  CC      fs/fs_pin.o
  CC      mm/swap_state.o
  CC      crypto/chainiv.o
  CC      fs/buffer.o
  LD      arch/mips/kernel/built-in.o
  CC      mm/swapfile.o
  CC      crypto/eseqiv.o
  CC      fs/block_dev.o
  CC      mm/migrate.o
  CC      crypto/ahash.o
  CC      crypto/pcompress.o
  CC      mm/slab.o
  CC      mm/dmapool.o
  CC      crypto/akcipher.o
  LD      arch/mips/mm/built-in.o
  CC      crypto/shash.o
  CC      fs/direct-io.o
  LD      kernel/irq/built-in.o
  CC      block/blk-softirq.o
  LD      arch/mips/built-in.o
  CC      crypto/algboss.o
  CC      block/blk-timeout.o
  CC      crypto/testmgr.o
  CC      block/blk-lib.o
  CC      crypto/hmac.o
  CC      block/blk-mq.o
  CC      crypto/crypto_null.o
  CC      crypto/md5.o
  CC      block/blk-mq-sysfs.o
  LD      kernel/rcu/built-in.o
  CC      block/blk-mq-tag.o
  CC      block/blk-mq-cpu.o
  CC      fs/mpage.o
  CC      block/blk-mq-cpumap.o
  LD      drivers/auxdisplay/built-in.o
  CC      block/ioctl.o
  LD      drivers/amba/built-in.o
  CC      block/scsi_ioctl.o
  CC      block/partition-generic.o
  CC      fs/proc_namespace.o
  LD      drivers/block/built-in.o
  CC      crypto/aes_generic.o
  CC      block/badblocks.o
  CC      block/genhd.o
  CC      block/ioprio.o
  CC      block/bsg-lib.o
  CC      block/bsg.o
  LD      drivers/bus/built-in.o
  CC      block/noop-iosched.o
  CC      crypto/crc32c_generic.o
  LD      drivers/block/aoe/built-in.o
  CC      block/deadline-iosched.o
  CC      block/partitions/check.o
  LD      arch/mips/fw/arc/built-in.o
  CC      block/partitions/msdos.o
  CC      net/socket.o
  CC      drivers/cdrom/cdrom.o
  CC      arch/mips/fw/arc/arc_con.o
  CC      block/cfq-iosched.o
  CC      crypto/rng.o
  LD      crypto/crypto.o
  LD      fs/exofs/built-in.o
  LD      fs/autofs4/built-in.o
  LD      net/802/built-in.o
  CC      drivers/char/mem.o
  LD      fs/exportfs/built-in.o
  CC      fs/devpts/inode.o
  CC      drivers/char/random.o
  CC      drivers/char/misc.o
  LD      net/dns_resolver/built-in.o
  LD      fs/efs/built-in.o
  LD      drivers/char/agp/built-in.o
  LD      fs/coda/built-in.o
  CC      drivers/base/component.o
  CC      block/partitions/sgi.o
  CC      arch/mips/fw/arc/cmdline.o
  CC      block/partitions/efi.o
  LD      drivers/clk/bcm/built-in.o
  CC      drivers/base/core.o
  CC      drivers/clocksource/i8253.o
  CC      net/ethernet/eth.o
  LD      drivers/clk/built-in.o
  LD      fs/ext2/built-in.o
  LD      drivers/connector/built-in.o
  CC      arch/mips/fw/arc/env.o
  LD      fs/cifs/built-in.o
  CC      net/key/af_key.o
  CC      arch/mips/fw/arc/file.o
  LD      drivers/crypto/built-in.o
  LD      fs/fuse/built-in.o
  LD      drivers/firewire/built-in.o
  CC      drivers/base/bus.o
  CC      arch/mips/fw/arc/identify.o
  CC      lib/lockref.o
  CC      net/netlink/af_netlink.o
  LD      arch/mips/fw/lib/built-in.o
  CC      arch/mips/fw/lib/cmdline.o
  LD      fs/fat/built-in.o
  CC      net/packet/af_packet.o
  CC      net/core/request_sock.o
  CC      net/core/sock.o
  CC      arch/mips/fw/arc/init.o
  CC      net/core/skbuff.o
  LD      kernel/printk/built-in.o
  CC      net/core/datagram.o
  CC      net/core/stream.o
  CC      net/core/scm.o
  LD      fs/isofs/built-in.o
  CC      fs/jbd2/commit.o
  CC      fs/jbd2/transaction.o
  CC      fs/kernfs/mount.o
  CC      net/netfilter/nf_log.o
  CC      net/core/gen_stats.o
  CC      net/netfilter/core.o
  LD      net/phonet/built-in.o
  CC      fs/kernfs/inode.o
  CC      fs/jbd2/recovery.o
  CC      fs/jbd2/revoke.o
  CC      fs/jbd2/journal.o
  LD      drivers/firmware/broadcom/built-in.o
  CC      fs/jbd2/checkpoint.o
  LD      drivers/gpio/built-in.o
  CC      fs/kernfs/dir.o
  CC      arch/mips/lib/iomap.o
  LD      fs/nfs_common/built-in.o
  LD      fs/nls/built-in.o
  LD      fs/minix/built-in.o
  CC      arch/mips/fw/arc/misc.o
  CC      fs/kernfs/file.o
  CC      fs/ext4/balloc.o
  LD      drivers/firmware/built-in.o
  CC      fs/kernfs/symlink.o
  CC      net/core/gen_estimator.o
  CC      drivers/base/dd.o
  AR      arch/mips/fw/lib/lib.a
  CC      net/core/secure_seq.o
  CC      net/core/net_namespace.o
  LD      fs/lockd/built-in.o
  CC      net/core/flow_dissector.o
  CC      arch/mips/lib/dump_tlb.o
  CC      net/netfilter/nf_queue.o
  CC      net/core/dev.o
  CC      net/core/sysctl_net_core.o
  CC      net/netfilter/nf_sockopt.o
  CC      net/core/dev_addr_lists.o
  CC      net/core/dst.o
  CC      net/core/neighbour.o
  CC      arch/mips/fw/arc/promlib.o
  CC      net/core/ethtool.o
  LD      net/rfkill/built-in.o
  CC      net/core/rtnetlink.o
  CC      net/core/netevent.o
  LD      fs/nfsd/built-in.o
  CC      net/core/utils.o
  LD      crypto/cryptomgr.o
  CC      net/core/link_watch.o
  CC      net/core/sock_diag.o
  CC      net/core/filter.o
  CC      net/core/tso.o
  CC      net/core/dev_ioctl.o
  LD      fs/nfs/built-in.o
  CC      lib/div64.o
  CC      lib/bcd.o
  CC      drivers/base/syscore.o
  CC      fs/ext4/dir.o
  CC      net/ipv6/af_inet6.o
  CC      net/ipv6/anycast.o
  CC      fs/ext4/bitmap.o
  CC      net/sched/sch_generic.o
  CC      net/ipv6/ip6_output.o
  LD      fs/omfs/built-in.o
  CC      arch/mips/fw/arc/salone.o
  LD      drivers/clocksource/built-in.o
  CC      net/ipv4/inetpeer.o
  CC      net/ipv4/route.o
  LD      fs/devpts/devpts.o
  CC      arch/mips/lib/ashrdi3.o
  CC      arch/mips/lib/ashldi3.o
  CC      lib/sort.o
/home/mingo/tip/mm/page_alloc.c: In function 'free_area_init_nodes':
/home/mingo/tip/mm/page_alloc.c:5712:34: warning: array subscript is below array bounds [-Warray-bounds]
    arch_zone_highest_possible_pfn[i-1];
                                  ^
  CC      net/ipv6/ip6_input.o
  LD      kernel/sched/built-in.o
  LD      fs/devpts/built-in.o
  CC      net/sched/sch_mq.o
  CC      fs/notify/fsnotify.o
  LD      virt/lib/built-in.o
  CC      fs/ext4/file.o
  CC      drivers/hid/hid-core.o
  CC      fs/ext4/fsync.o
  CC      fs/ext4/ialloc.o
  LD      virt/built-in.o
  CC      lib/parser.o
  CC      arch/mips/fw/arc/time.o
  LD      drivers/gpu/vga/built-in.o
  CC      net/sched/sch_api.o
  LD      drivers/gpu/drm/bridge/built-in.o
  LD      drivers/hsi/clients/built-in.o
  CC      net/ipv4/protocol.o
  CC      arch/mips/math-emu/cp1emu.o
  LD      kernel/time/built-in.o
  CC      fs/notify/notification.o
  CC      drivers/base/driver.o
  LD      drivers/gpu/drm/i2c/built-in.o
  CC      drivers/hid/hid-input.o
  CC      drivers/base/class.o
  CC      arch/mips/lib/bswapsi.o
  CC      arch/mips/lib/bswapdi.o
  CC      arch/mips/lib/cmpdi2.o
  LD      block/partitions/built-in.o
/home/mingo/tip/Makefile:950: recipe for target 'kernel' failed
make[1]: *** [kernel] Error 2
make[1]: *** Waiting for unfinished jobs....
  CC      arch/mips/math-emu/ieee754dp.o
  LD      drivers/hsi/controllers/built-in.o
  CC      drivers/base/platform.o
  CC      drivers/hid/hidraw.o
  CC      arch/mips/lib/lshrdi3.o
  CC      arch/mips/lib/ucmpdi2.o
  LD      drivers/gpu/drm/tilcdc/built-in.o
  LD      drivers/gpu/drm/panel/built-in.o
  LD      drivers/hsi/built-in.o
  AS      arch/mips/lib/csum_partial.o
  CC      fs/proc/task_mmu.o
  LD      drivers/hwtracing/intel_th/built-in.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
