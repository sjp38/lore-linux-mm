Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A535D90002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:18:22 -0400 (EDT)
Received: by pablj1 with SMTP id lj1so10982904pab.10
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 05:18:22 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.226])
        by mx.google.com with ESMTP id cj16si7085033pdb.23.2015.03.11.05.18.18
        for <linux-mm@kvack.org>;
        Wed, 11 Mar 2015 05:18:19 -0700 (PDT)
Date: Wed, 11 Mar 2015 08:19:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: kill kmemcheck
Message-ID: <20150311081909.552e2052@grimm.local.home>
In-Reply-To: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org


I removed the Cc list as it was so large, I'm sure that it exceeded the
LKML Cc size limit, and your email probably didn't make it to the list
(or any of them).

On Wed, 11 Mar 2015 07:43:59 -0400
Sasha Levin <sasha.levin@oracle.com> wrote:

> As discussed on LSF/MM, kill kmemcheck.
> 
> KASan is a replacement that is able to work without the limitation of
> kmemcheck (single CPU, slow). KASan is already upstream.
> 
> We are also not aware of any users of kmemcheck (or users who don't consider
> KASan as a suitable replacement).

I use kmemcheck and I am unaware of KASan. I'll try to play with KASan
and see if it suites my needs.

Thanks!

-- Steve


> 
> I've build tested it using all[yes,no,mod]config and fuzzed a bit with this
> patch applied, didn't notice any bad behaviour.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  Documentation/00-INDEX                       |    2 -
>  Documentation/kasan.txt                      |    7 +-
>  Documentation/kernel-parameters.txt          |    7 -
>  Documentation/kmemcheck.txt                  |  754 --------------------------
>  MAINTAINERS                                  |   10 -
>  arch/arm/include/asm/dma-iommu.h             |    1 -
>  arch/arm/include/asm/pgalloc.h               |    2 +-
>  arch/arm64/include/asm/pgalloc.h             |    2 +-
>  arch/openrisc/include/asm/dma-mapping.h      |    1 -
>  arch/powerpc/mm/pgtable_64.c                 |    3 +-
>  arch/sh/kernel/dwarf.c                       |    4 +-
>  arch/sh/kernel/process.c                     |    2 +-
>  arch/sparc/mm/init_64.c                      |    6 +-
>  arch/unicore32/include/asm/pgalloc.h         |    2 +-
>  arch/x86/Kconfig                             |    3 +-
>  arch/x86/Makefile                            |    5 -
>  arch/x86/include/asm/dma-mapping.h           |    1 -
>  arch/x86/include/asm/kmemcheck.h             |   42 --
>  arch/x86/include/asm/pgtable.h               |    5 -
>  arch/x86/include/asm/pgtable_types.h         |   13 -
>  arch/x86/include/asm/string_32.h             |    9 -
>  arch/x86/include/asm/string_64.h             |    8 -
>  arch/x86/include/asm/xor.h                   |    5 +-
>  arch/x86/kernel/cpu/intel.c                  |   15 -
>  arch/x86/kernel/espfix_64.c                  |    2 +-
>  arch/x86/kernel/process.c                    |    2 +-
>  arch/x86/kernel/traps.c                      |    5 -
>  arch/x86/mm/Makefile                         |    2 -
>  arch/x86/mm/fault.c                          |   10 -
>  arch/x86/mm/init.c                           |    4 +-
>  arch/x86/mm/init_64.c                        |    2 +-
>  arch/x86/mm/kmemcheck/Makefile               |    1 -
>  arch/x86/mm/kmemcheck/error.c                |  227 --------
>  arch/x86/mm/kmemcheck/error.h                |   15 -
>  arch/x86/mm/kmemcheck/kmemcheck.c            |  659 ----------------------
>  arch/x86/mm/kmemcheck/opcode.c               |  106 ----
>  arch/x86/mm/kmemcheck/opcode.h               |    9 -
>  arch/x86/mm/kmemcheck/pte.c                  |   22 -
>  arch/x86/mm/kmemcheck/pte.h                  |   10 -
>  arch/x86/mm/kmemcheck/selftest.c             |   70 ---
>  arch/x86/mm/kmemcheck/selftest.h             |    6 -
>  arch/x86/mm/kmemcheck/shadow.c               |  173 ------
>  arch/x86/mm/kmemcheck/shadow.h               |   18 -
>  arch/x86/mm/pageattr.c                       |    8 +-
>  arch/x86/mm/pgtable.c                        |    2 +-
>  crypto/xor.c                                 |    7 +-
>  drivers/char/random.c                        |    1 -
>  drivers/misc/c2port/core.c                   |    2 -
>  fs/dcache.c                                  |    2 -
>  include/asm-generic/dma-mapping-common.h     |    8 +-
>  include/linux/c2port.h                       |    4 -
>  include/linux/gfp.h                          |    8 -
>  include/linux/interrupt.h                    |    2 +
>  include/linux/kmemcheck.h                    |  171 ------
>  include/linux/mm_types.h                     |    8 -
>  include/linux/net.h                          |    3 -
>  include/linux/ring_buffer.h                  |    3 -
>  include/linux/skbuff.h                       |    3 -
>  include/linux/slab.h                         |    6 -
>  include/linux/thread_info.h                  |    4 +-
>  include/net/inet_sock.h                      |    7 +-
>  include/net/inet_timewait_sock.h             |    3 -
>  include/net/sock.h                           |    2 -
>  include/trace/events/gfpflags.h              |    1 -
>  init/do_mounts.c                             |    3 +-
>  init/main.c                                  |    1 -
>  kernel/fork.c                                |   14 +-
>  kernel/locking/lockdep.c                     |    3 -
>  kernel/signal.c                              |    3 +-
>  kernel/sysctl.c                              |   10 -
>  kernel/trace/ring_buffer.c                   |    3 -
>  lib/Kconfig.debug                            |    6 +-
>  lib/Kconfig.kmemcheck                        |   94 ----
>  mm/Kconfig.debug                             |    1 -
>  mm/Makefile                                  |    1 -
>  mm/kmemcheck.c                               |  123 -----
>  mm/kmemleak.c                                |    9 -
>  mm/page_alloc.c                              |   14 -
>  mm/slab.c                                    |   30 +-
>  mm/slab.h                                    |    4 +-
>  mm/slab_common.c                             |    2 +-
>  mm/slub.c                                    |   29 +-
>  net/core/skbuff.c                            |    5 -
>  net/core/sock.c                              |    2 -
>  net/ipv4/inet_timewait_sock.c                |    3 -
>  net/socket.c                                 |    1 -
>  scripts/kernel-doc                           |    2 -
>  tools/lib/lockdep/uinclude/linux/kmemcheck.h |    8 -
>  88 files changed, 52 insertions(+), 2826 deletions(-)
>  delete mode 100644 Documentation/kmemcheck.txt
>  delete mode 100644 arch/x86/include/asm/kmemcheck.h
>  delete mode 100644 arch/x86/mm/kmemcheck/Makefile
>  delete mode 100644 arch/x86/mm/kmemcheck/error.c
>  delete mode 100644 arch/x86/mm/kmemcheck/error.h
>  delete mode 100644 arch/x86/mm/kmemcheck/kmemcheck.c
>  delete mode 100644 arch/x86/mm/kmemcheck/opcode.c
>  delete mode 100644 arch/x86/mm/kmemcheck/opcode.h
>  delete mode 100644 arch/x86/mm/kmemcheck/pte.c
>  delete mode 100644 arch/x86/mm/kmemcheck/pte.h
>  delete mode 100644 arch/x86/mm/kmemcheck/selftest.c
>  delete mode 100644 arch/x86/mm/kmemcheck/selftest.h
>  delete mode 100644 arch/x86/mm/kmemcheck/shadow.c
>  delete mode 100644 arch/x86/mm/kmemcheck/shadow.h
>  delete mode 100644 include/linux/kmemcheck.h
>  delete mode 100644 lib/Kconfig.kmemcheck
>  delete mode 100644 mm/kmemcheck.c
>  delete mode 100644 tools/lib/lockdep/uinclude/linux/kmemcheck.h
> 
> diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
> index cd077ca..fb79009 100644
> --- a/Documentation/00-INDEX
> +++ b/Documentation/00-INDEX
> @@ -263,8 +263,6 @@ kernel-parameters.txt
>  	- summary listing of command line / boot prompt args for the kernel.
>  kernel-per-CPU-kthreads.txt
>  	- List of all per-CPU kthreads and how they introduce jitter.
> -kmemcheck.txt
> -	- info on dynamic checker that detects uses of uninitialized memory.
>  kmemleak.txt
>  	- info on how to make use of the kernel memory leak detection system
>  ko_KR/
> diff --git a/Documentation/kasan.txt b/Documentation/kasan.txt
> index 092fc10..a64d606 100644
> --- a/Documentation/kasan.txt
> +++ b/Documentation/kasan.txt
> @@ -139,10 +139,9 @@ the accessed address is partially accessible.
>  2. Implementation details
>  ========================
>  
> -From a high level, our approach to memory error detection is similar to that
> -of kmemcheck: use shadow memory to record whether each byte of memory is safe
> -to access, and use compile-time instrumentation to check shadow memory on each
> -memory access.
> +From a high level, our approach to memory error detection is: use shadow memory
> +to record whether each byte of memory is safe to access, and use compile-time
> +instrumentation to check shadow memory on each memory access.
>  
>  AddressSanitizer dedicates 1/8 of kernel memory to its shadow memory
>  (e.g. 16TB to cover 128TB on x86_64) and uses direct mapping with a scale and
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 8d5963f..0a68e3d 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1643,13 +1643,6 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			Built with CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y,
>  			the default is off.
>  
> -	kmemcheck=	[X86] Boot-time kmemcheck enable/disable/one-shot mode
> -			Valid arguments: 0, 1, 2
> -			kmemcheck=0 (disabled)
> -			kmemcheck=1 (enabled)
> -			kmemcheck=2 (one-shot mode)
> -			Default: 2 (one-shot mode)
> -
>  	kstack=N	[X86] Print N words from the kernel stack
>  			in oops dumps.
>  
> diff --git a/Documentation/kmemcheck.txt b/Documentation/kmemcheck.txt
> deleted file mode 100644
> index a41bdeb..0000000
> --- a/Documentation/kmemcheck.txt
> +++ /dev/null
> @@ -1,754 +0,0 @@
> -GETTING STARTED WITH KMEMCHECK
> -==============================
> -
> -Vegard Nossum <vegardno@ifi.uio.no>
> -
> -
> -Contents
> -========
> -0. Introduction
> -1. Downloading
> -2. Configuring and compiling
> -3. How to use
> -3.1. Booting
> -3.2. Run-time enable/disable
> -3.3. Debugging
> -3.4. Annotating false positives
> -4. Reporting errors
> -5. Technical description
> -
> -
> -0. Introduction
> -===============
> -
> -kmemcheck is a debugging feature for the Linux Kernel. More specifically, it
> -is a dynamic checker that detects and warns about some uses of uninitialized
> -memory.
> -
> -Userspace programmers might be familiar with Valgrind's memcheck. The main
> -difference between memcheck and kmemcheck is that memcheck works for userspace
> -programs only, and kmemcheck works for the kernel only. The implementations
> -are of course vastly different. Because of this, kmemcheck is not as accurate
> -as memcheck, but it turns out to be good enough in practice to discover real
> -programmer errors that the compiler is not able to find through static
> -analysis.
> -
> -Enabling kmemcheck on a kernel will probably slow it down to the extent that
> -the machine will not be usable for normal workloads such as e.g. an
> -interactive desktop. kmemcheck will also cause the kernel to use about twice
> -as much memory as normal. For this reason, kmemcheck is strictly a debugging
> -feature.
> -
> -
> -1. Downloading
> -==============
> -
> -As of version 2.6.31-rc1, kmemcheck is included in the mainline kernel.
> -
> -
> -2. Configuring and compiling
> -============================
> -
> -kmemcheck only works for the x86 (both 32- and 64-bit) platform. A number of
> -configuration variables must have specific settings in order for the kmemcheck
> -menu to even appear in "menuconfig". These are:
> -
> -  o CONFIG_CC_OPTIMIZE_FOR_SIZE=n
> -
> -	This option is located under "General setup" / "Optimize for size".
> -
> -	Without this, gcc will use certain optimizations that usually lead to
> -	false positive warnings from kmemcheck. An example of this is a 16-bit
> -	field in a struct, where gcc may load 32 bits, then discard the upper
> -	16 bits. kmemcheck sees only the 32-bit load, and may trigger a
> -	warning for the upper 16 bits (if they're uninitialized).
> -
> -  o CONFIG_SLAB=y or CONFIG_SLUB=y
> -
> -	This option is located under "General setup" / "Choose SLAB
> -	allocator".
> -
> -  o CONFIG_FUNCTION_TRACER=n
> -
> -	This option is located under "Kernel hacking" / "Tracers" / "Kernel
> -	Function Tracer"
> -
> -	When function tracing is compiled in, gcc emits a call to another
> -	function at the beginning of every function. This means that when the
> -	page fault handler is called, the ftrace framework will be called
> -	before kmemcheck has had a chance to handle the fault. If ftrace then
> -	modifies memory that was tracked by kmemcheck, the result is an
> -	endless recursive page fault.
> -
> -  o CONFIG_DEBUG_PAGEALLOC=n
> -
> -	This option is located under "Kernel hacking" / "Debug page memory
> -	allocations".
> -
> -In addition, I highly recommend turning on CONFIG_DEBUG_INFO=y. This is also
> -located under "Kernel hacking". With this, you will be able to get line number
> -information from the kmemcheck warnings, which is extremely valuable in
> -debugging a problem. This option is not mandatory, however, because it slows
> -down the compilation process and produces a much bigger kernel image.
> -
> -Now the kmemcheck menu should be visible (under "Kernel hacking" / "Memory
> -Debugging" / "kmemcheck: trap use of uninitialized memory"). Here follows
> -a description of the kmemcheck configuration variables:
> -
> -  o CONFIG_KMEMCHECK
> -
> -	This must be enabled in order to use kmemcheck at all...
> -
> -  o CONFIG_KMEMCHECK_[DISABLED | ENABLED | ONESHOT]_BY_DEFAULT
> -
> -	This option controls the status of kmemcheck at boot-time. "Enabled"
> -	will enable kmemcheck right from the start, "disabled" will boot the
> -	kernel as normal (but with the kmemcheck code compiled in, so it can
> -	be enabled at run-time after the kernel has booted), and "one-shot" is
> -	a special mode which will turn kmemcheck off automatically after
> -	detecting the first use of uninitialized memory.
> -
> -	If you are using kmemcheck to actively debug a problem, then you
> -	probably want to choose "enabled" here.
> -
> -	The one-shot mode is mostly useful in automated test setups because it
> -	can prevent floods of warnings and increase the chances of the machine
> -	surviving in case something is really wrong. In other cases, the one-
> -	shot mode could actually be counter-productive because it would turn
> -	itself off at the very first error -- in the case of a false positive
> -	too -- and this would come in the way of debugging the specific
> -	problem you were interested in.
> -
> -	If you would like to use your kernel as normal, but with a chance to
> -	enable kmemcheck in case of some problem, it might be a good idea to
> -	choose "disabled" here. When kmemcheck is disabled, most of the run-
> -	time overhead is not incurred, and the kernel will be almost as fast
> -	as normal.
> -
> -  o CONFIG_KMEMCHECK_QUEUE_SIZE
> -
> -	Select the maximum number of error reports to store in an internal
> -	(fixed-size) buffer. Since errors can occur virtually anywhere and in
> -	any context, we need a temporary storage area which is guaranteed not
> -	to generate any other page faults when accessed. The queue will be
> -	emptied as soon as a tasklet may be scheduled. If the queue is full,
> -	new error reports will be lost.
> -
> -	The default value of 64 is probably fine. If some code produces more
> -	than 64 errors within an irqs-off section, then the code is likely to
> -	produce many, many more, too, and these additional reports seldom give
> -	any more information (the first report is usually the most valuable
> -	anyway).
> -
> -	This number might have to be adjusted if you are not using serial
> -	console or similar to capture the kernel log. If you are using the
> -	"dmesg" command to save the log, then getting a lot of kmemcheck
> -	warnings might overflow the kernel log itself, and the earlier reports
> -	will get lost in that way instead. Try setting this to 10 or so on
> -	such a setup.
> -
> -  o CONFIG_KMEMCHECK_SHADOW_COPY_SHIFT
> -
> -	Select the number of shadow bytes to save along with each entry of the
> -	error-report queue. These bytes indicate what parts of an allocation
> -	are initialized, uninitialized, etc. and will be displayed when an
> -	error is detected to help the debugging of a particular problem.
> -
> -	The number entered here is actually the logarithm of the number of
> -	bytes that will be saved. So if you pick for example 5 here, kmemcheck
> -	will save 2^5 = 32 bytes.
> -
> -	The default value should be fine for debugging most problems. It also
> -	fits nicely within 80 columns.
> -
> -  o CONFIG_KMEMCHECK_PARTIAL_OK
> -
> -	This option (when enabled) works around certain GCC optimizations that
> -	produce 32-bit reads from 16-bit variables where the upper 16 bits are
> -	thrown away afterwards.
> -
> -	The default value (enabled) is recommended. This may of course hide
> -	some real errors, but disabling it would probably produce a lot of
> -	false positives.
> -
> -  o CONFIG_KMEMCHECK_BITOPS_OK
> -
> -	This option silences warnings that would be generated for bit-field
> -	accesses where not all the bits are initialized at the same time. This
> -	may also hide some real bugs.
> -
> -	This option is probably obsolete, or it should be replaced with
> -	the kmemcheck-/bitfield-annotations for the code in question. The
> -	default value is therefore fine.
> -
> -Now compile the kernel as usual.
> -
> -
> -3. How to use
> -=============
> -
> -3.1. Booting
> -============
> -
> -First some information about the command-line options. There is only one
> -option specific to kmemcheck, and this is called "kmemcheck". It can be used
> -to override the default mode as chosen by the CONFIG_KMEMCHECK_*_BY_DEFAULT
> -option. Its possible settings are:
> -
> -  o kmemcheck=0 (disabled)
> -  o kmemcheck=1 (enabled)
> -  o kmemcheck=2 (one-shot mode)
> -
> -If SLUB debugging has been enabled in the kernel, it may take precedence over
> -kmemcheck in such a way that the slab caches which are under SLUB debugging
> -will not be tracked by kmemcheck. In order to ensure that this doesn't happen
> -(even though it shouldn't by default), use SLUB's boot option "slub_debug",
> -like this: slub_debug=-
> -
> -In fact, this option may also be used for fine-grained control over SLUB vs.
> -kmemcheck. For example, if the command line includes "kmemcheck=1
> -slub_debug=,dentry", then SLUB debugging will be used only for the "dentry"
> -slab cache, and with kmemcheck tracking all the other caches. This is advanced
> -usage, however, and is not generally recommended.
> -
> -
> -3.2. Run-time enable/disable
> -============================
> -
> -When the kernel has booted, it is possible to enable or disable kmemcheck at
> -run-time. WARNING: This feature is still experimental and may cause false
> -positive warnings to appear. Therefore, try not to use this. If you find that
> -it doesn't work properly (e.g. you see an unreasonable amount of warnings), I
> -will be happy to take bug reports.
> -
> -Use the file /proc/sys/kernel/kmemcheck for this purpose, e.g.:
> -
> -	$ echo 0 > /proc/sys/kernel/kmemcheck # disables kmemcheck
> -
> -The numbers are the same as for the kmemcheck= command-line option.
> -
> -
> -3.3. Debugging
> -==============
> -
> -A typical report will look something like this:
> -
> -WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (ffff88003e4a2024)
> -80000000000000000000000000000000000000000088ffff0000000000000000
> - i i i i u u u u i i i i i i i i u u u u u u u u u u u u u u u u
> -         ^
> -
> -Pid: 1856, comm: ntpdate Not tainted 2.6.29-rc5 #264 945P-A
> -RIP: 0010:[<ffffffff8104ede8>]  [<ffffffff8104ede8>] __dequeue_signal+0xc8/0x190
> -RSP: 0018:ffff88003cdf7d98  EFLAGS: 00210002
> -RAX: 0000000000000030 RBX: ffff88003d4ea968 RCX: 0000000000000009
> -RDX: ffff88003e5d6018 RSI: ffff88003e5d6024 RDI: ffff88003cdf7e84
> -RBP: ffff88003cdf7db8 R08: ffff88003e5d6000 R09: 0000000000000000
> -R10: 0000000000000080 R11: 0000000000000000 R12: 000000000000000e
> -R13: ffff88003cdf7e78 R14: ffff88003d530710 R15: ffff88003d5a98c8
> -FS:  0000000000000000(0000) GS:ffff880001982000(0063) knlGS:00000
> -CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> -CR2: ffff88003f806ea0 CR3: 000000003c036000 CR4: 00000000000006a0
> -DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> -DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
> - [<ffffffff8104f04e>] dequeue_signal+0x8e/0x170
> - [<ffffffff81050bd8>] get_signal_to_deliver+0x98/0x390
> - [<ffffffff8100b87d>] do_notify_resume+0xad/0x7d0
> - [<ffffffff8100c7b5>] int_signal+0x12/0x17
> - [<ffffffffffffffff>] 0xffffffffffffffff
> -
> -The single most valuable information in this report is the RIP (or EIP on 32-
> -bit) value. This will help us pinpoint exactly which instruction that caused
> -the warning.
> -
> -If your kernel was compiled with CONFIG_DEBUG_INFO=y, then all we have to do
> -is give this address to the addr2line program, like this:
> -
> -	$ addr2line -e vmlinux -i ffffffff8104ede8
> -	arch/x86/include/asm/string_64.h:12
> -	include/asm-generic/siginfo.h:287
> -	kernel/signal.c:380
> -	kernel/signal.c:410
> -
> -The "-e vmlinux" tells addr2line which file to look in. IMPORTANT: This must
> -be the vmlinux of the kernel that produced the warning in the first place! If
> -not, the line number information will almost certainly be wrong.
> -
> -The "-i" tells addr2line to also print the line numbers of inlined functions.
> -In this case, the flag was very important, because otherwise, it would only
> -have printed the first line, which is just a call to memcpy(), which could be
> -called from a thousand places in the kernel, and is therefore not very useful.
> -These inlined functions would not show up in the stack trace above, simply
> -because the kernel doesn't load the extra debugging information. This
> -technique can of course be used with ordinary kernel oopses as well.
> -
> -In this case, it's the caller of memcpy() that is interesting, and it can be
> -found in include/asm-generic/siginfo.h, line 287:
> -
> -281 static inline void copy_siginfo(struct siginfo *to, struct siginfo *from)
> -282 {
> -283         if (from->si_code < 0)
> -284                 memcpy(to, from, sizeof(*to));
> -285         else
> -286                 /* _sigchld is currently the largest know union member */
> -287                 memcpy(to, from, __ARCH_SI_PREAMBLE_SIZE + sizeof(from->_sifields._sigchld));
> -288 }
> -
> -Since this was a read (kmemcheck usually warns about reads only, though it can
> -warn about writes to unallocated or freed memory as well), it was probably the
> -"from" argument which contained some uninitialized bytes. Following the chain
> -of calls, we move upwards to see where "from" was allocated or initialized,
> -kernel/signal.c, line 380:
> -
> -359 static void collect_signal(int sig, struct sigpending *list, siginfo_t *info)
> -360 {
> -...
> -367         list_for_each_entry(q, &list->list, list) {
> -368                 if (q->info.si_signo == sig) {
> -369                         if (first)
> -370                                 goto still_pending;
> -371                         first = q;
> -...
> -377         if (first) {
> -378 still_pending:
> -379                 list_del_init(&first->list);
> -380                 copy_siginfo(info, &first->info);
> -381                 __sigqueue_free(first);
> -...
> -392         }
> -393 }
> -
> -Here, it is &first->info that is being passed on to copy_siginfo(). The
> -variable "first" was found on a list -- passed in as the second argument to
> -collect_signal(). We  continue our journey through the stack, to figure out
> -where the item on "list" was allocated or initialized. We move to line 410:
> -
> -395 static int __dequeue_signal(struct sigpending *pending, sigset_t *mask,
> -396                         siginfo_t *info)
> -397 {
> -...
> -410                 collect_signal(sig, pending, info);
> -...
> -414 }
> -
> -Now we need to follow the "pending" pointer, since that is being passed on to
> -collect_signal() as "list". At this point, we've run out of lines from the
> -"addr2line" output. Not to worry, we just paste the next addresses from the
> -kmemcheck stack dump, i.e.:
> -
> - [<ffffffff8104f04e>] dequeue_signal+0x8e/0x170
> - [<ffffffff81050bd8>] get_signal_to_deliver+0x98/0x390
> - [<ffffffff8100b87d>] do_notify_resume+0xad/0x7d0
> - [<ffffffff8100c7b5>] int_signal+0x12/0x17
> -
> -	$ addr2line -e vmlinux -i ffffffff8104f04e ffffffff81050bd8 \
> -		ffffffff8100b87d ffffffff8100c7b5
> -	kernel/signal.c:446
> -	kernel/signal.c:1806
> -	arch/x86/kernel/signal.c:805
> -	arch/x86/kernel/signal.c:871
> -	arch/x86/kernel/entry_64.S:694
> -
> -Remember that since these addresses were found on the stack and not as the
> -RIP value, they actually point to the _next_ instruction (they are return
> -addresses). This becomes obvious when we look at the code for line 446:
> -
> -422 int dequeue_signal(struct task_struct *tsk, sigset_t *mask, siginfo_t *info)
> -423 {
> -...
> -431                 signr = __dequeue_signal(&tsk->signal->shared_pending,
> -432                                          mask, info);
> -433                 /*
> -434                  * itimer signal ?
> -435                  *
> -436                  * itimers are process shared and we restart periodic
> -437                  * itimers in the signal delivery path to prevent DoS
> -438                  * attacks in the high resolution timer case. This is
> -439                  * compliant with the old way of self restarting
> -440                  * itimers, as the SIGALRM is a legacy signal and only
> -441                  * queued once. Changing the restart behaviour to
> -442                  * restart the timer in the signal dequeue path is
> -443                  * reducing the timer noise on heavy loaded !highres
> -444                  * systems too.
> -445                  */
> -446                 if (unlikely(signr == SIGALRM)) {
> -...
> -489 }
> -
> -So instead of looking at 446, we should be looking at 431, which is the line
> -that executes just before 446. Here we see that what we are looking for is
> -&tsk->signal->shared_pending.
> -
> -Our next task is now to figure out which function that puts items on this
> -"shared_pending" list. A crude, but efficient tool, is git grep:
> -
> -	$ git grep -n 'shared_pending' kernel/
> -	...
> -	kernel/signal.c:828:    pending = group ? &t->signal->shared_pending : &t->pending;
> -	kernel/signal.c:1339:   pending = group ? &t->signal->shared_pending : &t->pending;
> -	...
> -
> -There were more results, but none of them were related to list operations,
> -and these were the only assignments. We inspect the line numbers more closely
> -and find that this is indeed where items are being added to the list:
> -
> -816 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
> -817                         int group)
> -818 {
> -...
> -828         pending = group ? &t->signal->shared_pending : &t->pending;
> -...
> -851         q = __sigqueue_alloc(t, GFP_ATOMIC, (sig < SIGRTMIN &&
> -852                                              (is_si_special(info) ||
> -853                                               info->si_code >= 0)));
> -854         if (q) {
> -855                 list_add_tail(&q->list, &pending->list);
> -...
> -890 }
> -
> -and:
> -
> -1309 int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
> -1310 {
> -....
> -1339         pending = group ? &t->signal->shared_pending : &t->pending;
> -1340         list_add_tail(&q->list, &pending->list);
> -....
> -1347 }
> -
> -In the first case, the list element we are looking for, "q", is being returned
> -from the function __sigqueue_alloc(), which looks like an allocation function.
> -Let's take a look at it:
> -
> -187 static struct sigqueue *__sigqueue_alloc(struct task_struct *t, gfp_t flags,
> -188                                          int override_rlimit)
> -189 {
> -190         struct sigqueue *q = NULL;
> -191         struct user_struct *user;
> -192 
> -193         /*
> -194          * We won't get problems with the target's UID changing under us
> -195          * because changing it requires RCU be used, and if t != current, the
> -196          * caller must be holding the RCU readlock (by way of a spinlock) and
> -197          * we use RCU protection here
> -198          */
> -199         user = get_uid(__task_cred(t)->user);
> -200         atomic_inc(&user->sigpending);
> -201         if (override_rlimit ||
> -202             atomic_read(&user->sigpending) <=
> -203                         t->signal->rlim[RLIMIT_SIGPENDING].rlim_cur)
> -204                 q = kmem_cache_alloc(sigqueue_cachep, flags);
> -205         if (unlikely(q == NULL)) {
> -206                 atomic_dec(&user->sigpending);
> -207                 free_uid(user);
> -208         } else {
> -209                 INIT_LIST_HEAD(&q->list);
> -210                 q->flags = 0;
> -211                 q->user = user;
> -212         }
> -213 
> -214         return q;
> -215 }
> -
> -We see that this function initializes q->list, q->flags, and q->user. It seems
> -that now is the time to look at the definition of "struct sigqueue", e.g.:
> -
> -14 struct sigqueue {
> -15         struct list_head list;
> -16         int flags;
> -17         siginfo_t info;
> -18         struct user_struct *user;
> -19 };
> -
> -And, you might remember, it was a memcpy() on &first->info that caused the
> -warning, so this makes perfect sense. It also seems reasonable to assume that
> -it is the caller of __sigqueue_alloc() that has the responsibility of filling
> -out (initializing) this member.
> -
> -But just which fields of the struct were uninitialized? Let's look at
> -kmemcheck's report again:
> -
> -WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (ffff88003e4a2024)
> -80000000000000000000000000000000000000000088ffff0000000000000000
> - i i i i u u u u i i i i i i i i u u u u u u u u u u u u u u u u
> -         ^
> -
> -These first two lines are the memory dump of the memory object itself, and the
> -shadow bytemap, respectively. The memory object itself is in this case
> -&first->info. Just beware that the start of this dump is NOT the start of the
> -object itself! The position of the caret (^) corresponds with the address of
> -the read (ffff88003e4a2024).
> -
> -The shadow bytemap dump legend is as follows:
> -
> -  i - initialized
> -  u - uninitialized
> -  a - unallocated (memory has been allocated by the slab layer, but has not
> -      yet been handed off to anybody)
> -  f - freed (memory has been allocated by the slab layer, but has been freed
> -      by the previous owner)
> -
> -In order to figure out where (relative to the start of the object) the
> -uninitialized memory was located, we have to look at the disassembly. For
> -that, we'll need the RIP address again:
> -
> -RIP: 0010:[<ffffffff8104ede8>]  [<ffffffff8104ede8>] __dequeue_signal+0xc8/0x190
> -
> -	$ objdump -d --no-show-raw-insn vmlinux | grep -C 8 ffffffff8104ede8:
> -	ffffffff8104edc8:       mov    %r8,0x8(%r8)
> -	ffffffff8104edcc:       test   %r10d,%r10d
> -	ffffffff8104edcf:       js     ffffffff8104ee88 <__dequeue_signal+0x168>
> -	ffffffff8104edd5:       mov    %rax,%rdx
> -	ffffffff8104edd8:       mov    $0xc,%ecx
> -	ffffffff8104eddd:       mov    %r13,%rdi
> -	ffffffff8104ede0:       mov    $0x30,%eax
> -	ffffffff8104ede5:       mov    %rdx,%rsi
> -	ffffffff8104ede8:       rep movsl %ds:(%rsi),%es:(%rdi)
> -	ffffffff8104edea:       test   $0x2,%al
> -	ffffffff8104edec:       je     ffffffff8104edf0 <__dequeue_signal+0xd0>
> -	ffffffff8104edee:       movsw  %ds:(%rsi),%es:(%rdi)
> -	ffffffff8104edf0:       test   $0x1,%al
> -	ffffffff8104edf2:       je     ffffffff8104edf5 <__dequeue_signal+0xd5>
> -	ffffffff8104edf4:       movsb  %ds:(%rsi),%es:(%rdi)
> -	ffffffff8104edf5:       mov    %r8,%rdi
> -	ffffffff8104edf8:       callq  ffffffff8104de60 <__sigqueue_free>
> -
> -As expected, it's the "rep movsl" instruction from the memcpy() that causes
> -the warning. We know about REP MOVSL that it uses the register RCX to count
> -the number of remaining iterations. By taking a look at the register dump
> -again (from the kmemcheck report), we can figure out how many bytes were left
> -to copy:
> -
> -RAX: 0000000000000030 RBX: ffff88003d4ea968 RCX: 0000000000000009
> -
> -By looking at the disassembly, we also see that %ecx is being loaded with the
> -value $0xc just before (ffffffff8104edd8), so we are very lucky. Keep in mind
> -that this is the number of iterations, not bytes. And since this is a "long"
> -operation, we need to multiply by 4 to get the number of bytes. So this means
> -that the uninitialized value was encountered at 4 * (0xc - 0x9) = 12 bytes
> -from the start of the object.
> -
> -We can now try to figure out which field of the "struct siginfo" that was not
> -initialized. This is the beginning of the struct:
> -
> -40 typedef struct siginfo {
> -41         int si_signo;
> -42         int si_errno;
> -43         int si_code;
> -44                 
> -45         union {
> -..
> -92         } _sifields;
> -93 } siginfo_t;
> -
> -On 64-bit, the int is 4 bytes long, so it must the union member that has
> -not been initialized. We can verify this using gdb:
> -
> -	$ gdb vmlinux
> -	...
> -	(gdb) p &((struct siginfo *) 0)->_sifields
> -	$1 = (union {...} *) 0x10
> -
> -Actually, it seems that the union member is located at offset 0x10 -- which
> -means that gcc has inserted 4 bytes of padding between the members si_code
> -and _sifields. We can now get a fuller picture of the memory dump:
> -
> -         _----------------------------=> si_code
> -        /        _--------------------=> (padding)
> -       |        /        _------------=> _sifields(._kill._pid)
> -       |       |        /        _----=> _sifields(._kill._uid)
> -       |       |       |        / 
> --------|-------|-------|-------|
> -80000000000000000000000000000000000000000088ffff0000000000000000
> - i i i i u u u u i i i i i i i i u u u u u u u u u u u u u u u u
> -
> -This allows us to realize another important fact: si_code contains the value
> -0x80. Remember that x86 is little endian, so the first 4 bytes "80000000" are
> -really the number 0x00000080. With a bit of research, we find that this is
> -actually the constant SI_KERNEL defined in include/asm-generic/siginfo.h:
> -
> -144 #define SI_KERNEL       0x80            /* sent by the kernel from somewhere     */
> -
> -This macro is used in exactly one place in the x86 kernel: In send_signal()
> -in kernel/signal.c:
> -
> -816 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
> -817                         int group)
> -818 {
> -...
> -828         pending = group ? &t->signal->shared_pending : &t->pending;
> -...
> -851         q = __sigqueue_alloc(t, GFP_ATOMIC, (sig < SIGRTMIN &&
> -852                                              (is_si_special(info) ||
> -853                                               info->si_code >= 0)));
> -854         if (q) {
> -855                 list_add_tail(&q->list, &pending->list);
> -856                 switch ((unsigned long) info) {
> -...
> -865                 case (unsigned long) SEND_SIG_PRIV:
> -866                         q->info.si_signo = sig;
> -867                         q->info.si_errno = 0;
> -868                         q->info.si_code = SI_KERNEL;
> -869                         q->info.si_pid = 0;
> -870                         q->info.si_uid = 0;
> -871                         break;
> -...
> -890 }
> -
> -Not only does this match with the .si_code member, it also matches the place
> -we found earlier when looking for where siginfo_t objects are enqueued on the
> -"shared_pending" list.
> -
> -So to sum up: It seems that it is the padding introduced by the compiler
> -between two struct fields that is uninitialized, and this gets reported when
> -we do a memcpy() on the struct. This means that we have identified a false
> -positive warning.
> -
> -Normally, kmemcheck will not report uninitialized accesses in memcpy() calls
> -when both the source and destination addresses are tracked. (Instead, we copy
> -the shadow bytemap as well). In this case, the destination address clearly
> -was not tracked. We can dig a little deeper into the stack trace from above:
> -
> -	arch/x86/kernel/signal.c:805
> -	arch/x86/kernel/signal.c:871
> -	arch/x86/kernel/entry_64.S:694
> -
> -And we clearly see that the destination siginfo object is located on the
> -stack:
> -
> -782 static void do_signal(struct pt_regs *regs)
> -783 {
> -784         struct k_sigaction ka;
> -785         siginfo_t info;
> -...
> -804         signr = get_signal_to_deliver(&info, &ka, regs, NULL);
> -...
> -854 }
> -
> -And this &info is what eventually gets passed to copy_siginfo() as the
> -destination argument.
> -
> -Now, even though we didn't find an actual error here, the example is still a
> -good one, because it shows how one would go about to find out what the report
> -was all about.
> -
> -
> -3.4. Annotating false positives
> -===============================
> -
> -There are a few different ways to make annotations in the source code that
> -will keep kmemcheck from checking and reporting certain allocations. Here
> -they are:
> -
> -  o __GFP_NOTRACK_FALSE_POSITIVE
> -
> -	This flag can be passed to kmalloc() or kmem_cache_alloc() (therefore
> -	also to other functions that end up calling one of these) to indicate
> -	that the allocation should not be tracked because it would lead to
> -	a false positive report. This is a "big hammer" way of silencing
> -	kmemcheck; after all, even if the false positive pertains to 
> -	particular field in a struct, for example, we will now lose the
> -	ability to find (real) errors in other parts of the same struct.
> -
> -	Example:
> -
> -	    /* No warnings will ever trigger on accessing any part of x */
> -	    x = kmalloc(sizeof *x, GFP_KERNEL | __GFP_NOTRACK_FALSE_POSITIVE);
> -
> -  o kmemcheck_bitfield_begin(name)/kmemcheck_bitfield_end(name) and
> -	kmemcheck_annotate_bitfield(ptr, name)
> -
> -	The first two of these three macros can be used inside struct
> -	definitions to signal, respectively, the beginning and end of a
> -	bitfield. Additionally, this will assign the bitfield a name, which
> -	is given as an argument to the macros.
> -
> -	Having used these markers, one can later use
> -	kmemcheck_annotate_bitfield() at the point of allocation, to indicate
> -	which parts of the allocation is part of a bitfield.
> -
> -	Example:
> -
> -	    struct foo {
> -		int x;
> -
> -		kmemcheck_bitfield_begin(flags);
> -		int flag_a:1;
> -		int flag_b:1;
> -		kmemcheck_bitfield_end(flags);
> -
> -		int y;
> -	    };
> -
> -	    struct foo *x = kmalloc(sizeof *x);
> -
> -	    /* No warnings will trigger on accessing the bitfield of x */
> -	    kmemcheck_annotate_bitfield(x, flags);
> -
> -	Note that kmemcheck_annotate_bitfield() can be used even before the
> -	return value of kmalloc() is checked -- in other words, passing NULL
> -	as the first argument is legal (and will do nothing).
> -
> -
> -4. Reporting errors
> -===================
> -
> -As we have seen, kmemcheck will produce false positive reports. Therefore, it
> -is not very wise to blindly post kmemcheck warnings to mailing lists and
> -maintainers. Instead, I encourage maintainers and developers to find errors
> -in their own code. If you get a warning, you can try to work around it, try
> -to figure out if it's a real error or not, or simply ignore it. Most
> -developers know their own code and will quickly and efficiently determine the
> -root cause of a kmemcheck report. This is therefore also the most efficient
> -way to work with kmemcheck.
> -
> -That said, we (the kmemcheck maintainers) will always be on the lookout for
> -false positives that we can annotate and silence. So whatever you find,
> -please drop us a note privately! Kernel configs and steps to reproduce (if
> -available) are of course a great help too.
> -
> -Happy hacking!
> -
> -
> -5. Technical description
> -========================
> -
> -kmemcheck works by marking memory pages non-present. This means that whenever
> -somebody attempts to access the page, a page fault is generated. The page
> -fault handler notices that the page was in fact only hidden, and so it calls
> -on the kmemcheck code to make further investigations.
> -
> -When the investigations are completed, kmemcheck "shows" the page by marking
> -it present (as it would be under normal circumstances). This way, the
> -interrupted code can continue as usual.
> -
> -But after the instruction has been executed, we should hide the page again, so
> -that we can catch the next access too! Now kmemcheck makes use of a debugging
> -feature of the processor, namely single-stepping. When the processor has
> -finished the one instruction that generated the memory access, a debug
> -exception is raised. From here, we simply hide the page again and continue
> -execution, this time with the single-stepping feature turned off.
> -
> -kmemcheck requires some assistance from the memory allocator in order to work.
> -The memory allocator needs to
> -
> -  1. Tell kmemcheck about newly allocated pages and pages that are about to
> -     be freed. This allows kmemcheck to set up and tear down the shadow memory
> -     for the pages in question. The shadow memory stores the status of each
> -     byte in the allocation proper, e.g. whether it is initialized or
> -     uninitialized.
> -
> -  2. Tell kmemcheck which parts of memory should be marked uninitialized.
> -     There are actually a few more states, such as "not yet allocated" and
> -     "recently freed".
> -
> -If a slab cache is set up using the SLAB_NOTRACK flag, it will never return
> -memory that can take page faults because of kmemcheck.
> -
> -If a slab cache is NOT set up using the SLAB_NOTRACK flag, callers can still
> -request memory with the __GFP_NOTRACK or __GFP_NOTRACK_FALSE_POSITIVE flags.
> -This does not prevent the page faults from occurring, however, but marks the
> -object in question as being initialized so that no warnings will ever be
> -produced for this object.
> -
> -Currently, the SLAB and SLUB allocators are supported by kmemcheck.
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 1939f73..36e3ddb 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5706,16 +5706,6 @@ F:	include/linux/kdb.h
>  F:	include/linux/kgdb.h
>  F:	kernel/debug/
>  
> -KMEMCHECK
> -M:	Vegard Nossum <vegardno@ifi.uio.no>
> -M:	Pekka Enberg <penberg@kernel.org>
> -S:	Maintained
> -F:	Documentation/kmemcheck.txt
> -F:	arch/x86/include/asm/kmemcheck.h
> -F:	arch/x86/mm/kmemcheck/
> -F:	include/linux/kmemcheck.h
> -F:	mm/kmemcheck.c
> -
>  KMEMLEAK
>  M:	Catalin Marinas <catalin.marinas@arm.com>
>  S:	Maintained
> diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
> index 8e3fcb9..0e1c1f6 100644
> --- a/arch/arm/include/asm/dma-iommu.h
> +++ b/arch/arm/include/asm/dma-iommu.h
> @@ -6,7 +6,6 @@
>  #include <linux/mm_types.h>
>  #include <linux/scatterlist.h>
>  #include <linux/dma-debug.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/kref.h>
>  
>  struct dma_iommu_mapping {
> diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
> index 19cfab5..019414e 100644
> --- a/arch/arm/include/asm/pgalloc.h
> +++ b/arch/arm/include/asm/pgalloc.h
> @@ -57,7 +57,7 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
>  extern pgd_t *pgd_alloc(struct mm_struct *mm);
>  extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
>  
> -#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
> +#define PGALLOC_GFP	(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO)
>  
>  static inline void clean_pte_table(pte_t *pte)
>  {
> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> index 7642056..1d57e4b 100644
> --- a/arch/arm64/include/asm/pgalloc.h
> +++ b/arch/arm64/include/asm/pgalloc.h
> @@ -26,7 +26,7 @@
>  
>  #define check_pgt_cache()		do { } while (0)
>  
> -#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
> +#define PGALLOC_GFP	(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO)
>  
>  #if CONFIG_PGTABLE_LEVELS > 2
>  
> diff --git a/arch/openrisc/include/asm/dma-mapping.h b/arch/openrisc/include/asm/dma-mapping.h
> index fab8628..8226691 100644
> --- a/arch/openrisc/include/asm/dma-mapping.h
> +++ b/arch/openrisc/include/asm/dma-mapping.h
> @@ -24,7 +24,6 @@
>  
>  #include <linux/dma-debug.h>
>  #include <asm-generic/dma-coherent.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/dma-mapping.h>
>  
>  #define DMA_ERROR_CODE		(~(dma_addr_t)0x0)
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index 6957cc1..041f129 100644
> --- a/arch/powerpc/mm/pgtable_64.c
> +++ b/arch/powerpc/mm/pgtable_64.c
> @@ -396,8 +396,7 @@ static pte_t *get_from_cache(struct mm_struct *mm)
>  static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
>  {
>  	void *ret = NULL;
> -	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
> -				       __GFP_REPEAT | __GFP_ZERO);
> +	struct page *page = alloc_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
>  	if (!page)
>  		return NULL;
>  	if (!kernel && !pgtable_page_ctor(page)) {
> diff --git a/arch/sh/kernel/dwarf.c b/arch/sh/kernel/dwarf.c
> index 67a049e..eddc96a 100644
> --- a/arch/sh/kernel/dwarf.c
> +++ b/arch/sh/kernel/dwarf.c
> @@ -1170,11 +1170,11 @@ static int __init dwarf_unwinder_init(void)
>  
>  	dwarf_frame_cachep = kmem_cache_create("dwarf_frames",
>  			sizeof(struct dwarf_frame), 0,
> -			SLAB_PANIC | SLAB_HWCACHE_ALIGN | SLAB_NOTRACK, NULL);
> +			SLAB_PANIC | SLAB_HWCACHE_ALIGN, NULL);
>  
>  	dwarf_reg_cachep = kmem_cache_create("dwarf_regs",
>  			sizeof(struct dwarf_reg), 0,
> -			SLAB_PANIC | SLAB_HWCACHE_ALIGN | SLAB_NOTRACK, NULL);
> +			SLAB_PANIC | SLAB_HWCACHE_ALIGN, NULL);
>  
>  	dwarf_frame_pool = mempool_create(DWARF_FRAME_MIN_REQ,
>  					  mempool_alloc_slab,
> diff --git a/arch/sh/kernel/process.c b/arch/sh/kernel/process.c
> index 53bc6c4..20e0d4f 100644
> --- a/arch/sh/kernel/process.c
> +++ b/arch/sh/kernel/process.c
> @@ -56,7 +56,7 @@ void arch_task_cache_init(void)
>  
>  	task_xstate_cachep = kmem_cache_create("task_xstate", xstate_size,
>  					       __alignof__(union thread_xstate),
> -					       SLAB_PANIC | SLAB_NOTRACK, NULL);
> +					       SLAB_PANIC, NULL);
>  }
>  
>  #ifdef CONFIG_SH_FPU_EMU
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 3ea267c..dc3edc4 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -2610,8 +2610,7 @@ void __flush_tlb_all(void)
>  pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
>  			    unsigned long address)
>  {
> -	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
> -				       __GFP_REPEAT | __GFP_ZERO);
> +	struct page *page = alloc_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
>  	pte_t *pte = NULL;
>  
>  	if (page)
> @@ -2623,8 +2622,7 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
>  pgtable_t pte_alloc_one(struct mm_struct *mm,
>  			unsigned long address)
>  {
> -	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
> -				       __GFP_REPEAT | __GFP_ZERO);
> +	struct page *page = alloc_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
>  	if (!page)
>  		return NULL;
>  	if (!pgtable_page_ctor(page)) {
> diff --git a/arch/unicore32/include/asm/pgalloc.h b/arch/unicore32/include/asm/pgalloc.h
> index 2e02d13..408ba3c 100644
> --- a/arch/unicore32/include/asm/pgalloc.h
> +++ b/arch/unicore32/include/asm/pgalloc.h
> @@ -28,7 +28,7 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
>  #define pgd_alloc(mm)			get_pgd_slow(mm)
>  #define pgd_free(mm, pgd)		free_pgd_slow(mm, pgd)
>  
> -#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
> +#define PGALLOC_GFP	(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO)
>  
>  /*
>   * Allocate one PTE table.
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 110f6ae..3ab3339 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -84,7 +84,6 @@ config X86
>  	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
>  	select HAVE_CMPXCHG_LOCAL
>  	select HAVE_CMPXCHG_DOUBLE
> -	select HAVE_ARCH_KMEMCHECK
>  	select HAVE_ARCH_KASAN if X86_64 && SPARSEMEM_VMEMMAP
>  	select HAVE_USER_RETURN_NOTIFIER
>  	select ARCH_HAS_ELF_RANDOMIZE
> @@ -1304,7 +1303,7 @@ config ARCH_DMA_ADDR_T_64BIT
>  
>  config X86_DIRECT_GBPAGES
>  	def_bool y
> -	depends on X86_64 && !DEBUG_PAGEALLOC && !KMEMCHECK
> +	depends on X86_64 && !DEBUG_PAGEALLOC
>  	---help---
>  	  Certain kernel features effectively disable kernel
>  	  linear 1 GB mappings (even if the CPU otherwise
> diff --git a/arch/x86/Makefile b/arch/x86/Makefile
> index 5ba2d9c..fa827bf 100644
> --- a/arch/x86/Makefile
> +++ b/arch/x86/Makefile
> @@ -131,11 +131,6 @@ ifdef CONFIG_X86_X32
>  endif
>  export CONFIG_X86_X32_ABI
>  
> -# Don't unroll struct assignments with kmemcheck enabled
> -ifeq ($(CONFIG_KMEMCHECK),y)
> -	KBUILD_CFLAGS += $(call cc-option,-fno-builtin-memcpy)
> -endif
> -
>  # Stackpointer is addressed different for 32 bit and 64 bit x86
>  sp-$(CONFIG_X86_32) := esp
>  sp-$(CONFIG_X86_64) := rsp
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index 808dae6..51f0267 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -6,7 +6,6 @@
>   * Documentation/DMA-API.txt for documentation.
>   */
>  
> -#include <linux/kmemcheck.h>
>  #include <linux/scatterlist.h>
>  #include <linux/dma-debug.h>
>  #include <linux/dma-attrs.h>
> diff --git a/arch/x86/include/asm/kmemcheck.h b/arch/x86/include/asm/kmemcheck.h
> deleted file mode 100644
> index ed01518..0000000
> --- a/arch/x86/include/asm/kmemcheck.h
> +++ /dev/null
> @@ -1,42 +0,0 @@
> -#ifndef ASM_X86_KMEMCHECK_H
> -#define ASM_X86_KMEMCHECK_H
> -
> -#include <linux/types.h>
> -#include <asm/ptrace.h>
> -
> -#ifdef CONFIG_KMEMCHECK
> -bool kmemcheck_active(struct pt_regs *regs);
> -
> -void kmemcheck_show(struct pt_regs *regs);
> -void kmemcheck_hide(struct pt_regs *regs);
> -
> -bool kmemcheck_fault(struct pt_regs *regs,
> -	unsigned long address, unsigned long error_code);
> -bool kmemcheck_trap(struct pt_regs *regs);
> -#else
> -static inline bool kmemcheck_active(struct pt_regs *regs)
> -{
> -	return false;
> -}
> -
> -static inline void kmemcheck_show(struct pt_regs *regs)
> -{
> -}
> -
> -static inline void kmemcheck_hide(struct pt_regs *regs)
> -{
> -}
> -
> -static inline bool kmemcheck_fault(struct pt_regs *regs,
> -	unsigned long address, unsigned long error_code)
> -{
> -	return false;
> -}
> -
> -static inline bool kmemcheck_trap(struct pt_regs *regs)
> -{
> -	return false;
> -}
> -#endif /* CONFIG_KMEMCHECK */
> -
> -#endif
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index affcb34..85088d1 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -458,11 +458,6 @@ static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
>  	return false;
>  }
>  
> -static inline int pte_hidden(pte_t pte)
> -{
> -	return pte_flags(pte) & _PAGE_HIDDEN;
> -}
> -
>  static inline int pmd_present(pmd_t pmd)
>  {
>  	/*
> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
> index 78f0c8c..2d49d75 100644
> --- a/arch/x86/include/asm/pgtable_types.h
> +++ b/arch/x86/include/asm/pgtable_types.h
> @@ -23,7 +23,6 @@
>  #define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW1
>  #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
>  #define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW2 /* only valid on a PSE pmd */
> -#define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
>  #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
>  #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
>  
> @@ -49,18 +48,6 @@
>  #define _PAGE_SPLITTING	(_AT(pteval_t, 1) << _PAGE_BIT_SPLITTING)
>  #define __HAVE_ARCH_PTE_SPECIAL
>  
> -#ifdef CONFIG_KMEMCHECK
> -#define _PAGE_HIDDEN	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
> -#else
> -#define _PAGE_HIDDEN	(_AT(pteval_t, 0))
> -#endif
> -
> -/*
> - * The same hidden bit is used by kmemcheck, but since kmemcheck
> - * works on kernel pages while soft-dirty engine on user space,
> - * they do not conflict with each other.
> - */
> -
>  #ifdef CONFIG_MEM_SOFT_DIRTY
>  #define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_SOFT_DIRTY)
>  #else
> diff --git a/arch/x86/include/asm/string_32.h b/arch/x86/include/asm/string_32.h
> index 3d3e835..8a4f6fa 100644
> --- a/arch/x86/include/asm/string_32.h
> +++ b/arch/x86/include/asm/string_32.h
> @@ -176,8 +176,6 @@ static inline void *__memcpy3d(void *to, const void *from, size_t len)
>   *	No 3D Now!
>   */
>  
> -#ifndef CONFIG_KMEMCHECK
> -
>  #if (__GNUC__ >= 4)
>  #define memcpy(t, f, n) __builtin_memcpy(t, f, n)
>  #else
> @@ -186,13 +184,6 @@ static inline void *__memcpy3d(void *to, const void *from, size_t len)
>  	 ? __constant_memcpy((t), (f), (n))	\
>  	 : __memcpy((t), (f), (n)))
>  #endif
> -#else
> -/*
> - * kmemcheck becomes very happy if we use the REP instructions unconditionally,
> - * because it means that we know both memory operands in advance.
> - */
> -#define memcpy(t, f, n) __memcpy((t), (f), (n))
> -#endif
>  
>  #endif
>  
> diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
> index e466119..19da531 100644
> --- a/arch/x86/include/asm/string_64.h
> +++ b/arch/x86/include/asm/string_64.h
> @@ -29,7 +29,6 @@ static __always_inline void *__inline_memcpy(void *to, const void *from, size_t
>  #define __HAVE_ARCH_MEMCPY 1
>  extern void *__memcpy(void *to, const void *from, size_t len);
>  
> -#ifndef CONFIG_KMEMCHECK
>  #if (__GNUC__ == 4 && __GNUC_MINOR__ >= 3) || __GNUC__ > 4
>  extern void *memcpy(void *to, const void *from, size_t len);
>  #else
> @@ -44,13 +43,6 @@ extern void *memcpy(void *to, const void *from, size_t len);
>  	__ret;							\
>  })
>  #endif
> -#else
> -/*
> - * kmemcheck becomes very happy if we use the REP instructions unconditionally,
> - * because it means that we know both memory operands in advance.
> - */
> -#define memcpy(dst, src, len) __inline_memcpy((dst), (src), (len))
> -#endif
>  
>  #define __HAVE_ARCH_MEMSET
>  void *memset(void *s, int c, size_t n);
> diff --git a/arch/x86/include/asm/xor.h b/arch/x86/include/asm/xor.h
> index d882975..d484838 100644
> --- a/arch/x86/include/asm/xor.h
> +++ b/arch/x86/include/asm/xor.h
> @@ -1,7 +1,4 @@
> -#ifdef CONFIG_KMEMCHECK
> -/* kmemcheck doesn't handle MMX/SSE/SSE2 instructions */
> -# include <asm-generic/xor.h>
> -#elif !defined(_ASM_X86_XOR_H)
> +#ifndef _ASM_X86_XOR_H
>  #define _ASM_X86_XOR_H
>  
>  /*
> diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
> index 50163fa..422fceb 100644
> --- a/arch/x86/kernel/cpu/intel.c
> +++ b/arch/x86/kernel/cpu/intel.c
> @@ -117,21 +117,6 @@ static void early_init_intel(struct cpuinfo_x86 *c)
>  	if (c->x86 == 6 && c->x86_model < 15)
>  		clear_cpu_cap(c, X86_FEATURE_PAT);
>  
> -#ifdef CONFIG_KMEMCHECK
> -	/*
> -	 * P4s have a "fast strings" feature which causes single-
> -	 * stepping REP instructions to only generate a #DB on
> -	 * cache-line boundaries.
> -	 *
> -	 * Ingo Molnar reported a Pentium D (model 6) and a Xeon
> -	 * (model 2) with the same problem.
> -	 */
> -	if (c->x86 == 15)
> -		if (msr_clear_bit(MSR_IA32_MISC_ENABLE,
> -				  MSR_IA32_MISC_ENABLE_FAST_STRING_BIT) > 0)
> -			pr_info("kmemcheck: Disabling fast string operations\n");
> -#endif
> -
>  	/*
>  	 * If fast string is not enabled in IA32_MISC_ENABLE for any reason,
>  	 * clear the fast string and enhanced fast string CPU capabilities.
> diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
> index f5d0730..57870b2 100644
> --- a/arch/x86/kernel/espfix_64.c
> +++ b/arch/x86/kernel/espfix_64.c
> @@ -57,7 +57,7 @@
>  # error "Need more than one PGD for the ESPFIX hack"
>  #endif
>  
> -#define PGALLOC_GFP (GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
> +#define PGALLOC_GFP (GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO)
>  
>  /* This contains the *bottom* address of the espfix stack */
>  DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_stack);
> diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
> index 2f3a4e4..c7908d3 100644
> --- a/arch/x86/kernel/process.c
> +++ b/arch/x86/kernel/process.c
> @@ -114,7 +114,7 @@ void arch_task_cache_init(void)
>          task_xstate_cachep =
>          	kmem_cache_create("task_xstate", xstate_size,
>  				  __alignof__(union thread_xstate),
> -				  SLAB_PANIC | SLAB_NOTRACK, NULL);
> +				  SLAB_PANIC, NULL);
>  	setup_xstate_comp();
>  }
>  
> diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
> index 986fb20..8623044 100644
> --- a/arch/x86/kernel/traps.c
> +++ b/arch/x86/kernel/traps.c
> @@ -46,7 +46,6 @@
>  #include <linux/edac.h>
>  #endif
>  
> -#include <asm/kmemcheck.h>
>  #include <asm/stacktrace.h>
>  #include <asm/processor.h>
>  #include <asm/debugreg.h>
> @@ -640,10 +639,6 @@ dotraplinkage void do_debug(struct pt_regs *regs, long error_code)
>  	if (!dr6 && user_mode(regs))
>  		user_icebp = 1;
>  
> -	/* Catch kmemcheck conditions first of all! */
> -	if ((dr6 & DR_STEP) && kmemcheck_trap(regs))
> -		goto exit;
> -
>  	/* DR6 may or may not be cleared by the CPU */
>  	set_debugreg(0, 6);
>  
> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index c4cc740..afa8c79 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -18,8 +18,6 @@ obj-$(CONFIG_X86_PTDUMP)	+= dump_pagetables.o
>  
>  obj-$(CONFIG_HIGHMEM)		+= highmem_32.o
>  
> -obj-$(CONFIG_KMEMCHECK)		+= kmemcheck/
> -
>  KASAN_SANITIZE_kasan_init_$(BITS).o := n
>  obj-$(CONFIG_KASAN)		+= kasan_init_$(BITS).o
>  
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index ede025f..cd10e83 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -16,7 +16,6 @@
>  
>  #include <asm/traps.h>			/* dotraplinkage, ...		*/
>  #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
> -#include <asm/kmemcheck.h>		/* kmemcheck_*(), ...		*/
>  #include <asm/fixmap.h>			/* VSYSCALL_ADDR		*/
>  #include <asm/vsyscall.h>		/* emulate_vsyscall		*/
>  
> @@ -1063,12 +1062,6 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  	tsk = current;
>  	mm = tsk->mm;
>  
> -	/*
> -	 * Detect and handle instructions that would cause a page fault for
> -	 * both a tracked kernel page and a userspace page.
> -	 */
> -	if (kmemcheck_active(regs))
> -		kmemcheck_hide(regs);
>  	prefetchw(&mm->mmap_sem);
>  
>  	if (unlikely(kmmio_fault(regs, address)))
> @@ -1091,9 +1084,6 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  		if (!(error_code & (PF_RSVD | PF_USER | PF_PROT))) {
>  			if (vmalloc_fault(address) >= 0)
>  				return;
> -
> -			if (kmemcheck_fault(regs, address, error_code))
> -				return;
>  		}
>  
>  		/* Can handle a stale RO->RW TLB: */
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 1d55318..ab3ef36 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -86,7 +86,7 @@ __ref void *alloc_low_pages(unsigned int num)
>  		unsigned int order;
>  
>  		order = get_order((unsigned long)num << PAGE_SHIFT);
> -		return (void *)__get_free_pages(GFP_ATOMIC | __GFP_NOTRACK |
> +		return (void *)__get_free_pages(GFP_ATOMIC |
>  						__GFP_ZERO, order);
>  	}
>  
> @@ -147,7 +147,7 @@ static int page_size_mask;
>  
>  static void __init probe_page_size_mask(void)
>  {
> -#if !defined(CONFIG_DEBUG_PAGEALLOC) && !defined(CONFIG_KMEMCHECK)
> +#if !defined(CONFIG_DEBUG_PAGEALLOC)
>  	/*
>  	 * For CONFIG_DEBUG_PAGEALLOC, identity mapping will use small pages.
>  	 * This will simplify cpa(), which otherwise needs to support splitting
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 3fba623..6b82ba4 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -216,7 +216,7 @@ static __ref void *spp_getpage(void)
>  	void *ptr;
>  
>  	if (after_bootmem)
> -		ptr = (void *) get_zeroed_page(GFP_ATOMIC | __GFP_NOTRACK);
> +		ptr = (void *) get_zeroed_page(GFP_ATOMIC);
>  	else
>  		ptr = alloc_bootmem_pages(PAGE_SIZE);
>  
> diff --git a/arch/x86/mm/kmemcheck/Makefile b/arch/x86/mm/kmemcheck/Makefile
> deleted file mode 100644
> index 520b3bc..0000000
> --- a/arch/x86/mm/kmemcheck/Makefile
> +++ /dev/null
> @@ -1 +0,0 @@
> -obj-y := error.o kmemcheck.o opcode.o pte.o selftest.o shadow.o
> diff --git a/arch/x86/mm/kmemcheck/error.c b/arch/x86/mm/kmemcheck/error.c
> deleted file mode 100644
> index dab4187..0000000
> --- a/arch/x86/mm/kmemcheck/error.c
> +++ /dev/null
> @@ -1,227 +0,0 @@
> -#include <linux/interrupt.h>
> -#include <linux/kdebug.h>
> -#include <linux/kmemcheck.h>
> -#include <linux/kernel.h>
> -#include <linux/types.h>
> -#include <linux/ptrace.h>
> -#include <linux/stacktrace.h>
> -#include <linux/string.h>
> -
> -#include "error.h"
> -#include "shadow.h"
> -
> -enum kmemcheck_error_type {
> -	KMEMCHECK_ERROR_INVALID_ACCESS,
> -	KMEMCHECK_ERROR_BUG,
> -};
> -
> -#define SHADOW_COPY_SIZE (1 << CONFIG_KMEMCHECK_SHADOW_COPY_SHIFT)
> -
> -struct kmemcheck_error {
> -	enum kmemcheck_error_type type;
> -
> -	union {
> -		/* KMEMCHECK_ERROR_INVALID_ACCESS */
> -		struct {
> -			/* Kind of access that caused the error */
> -			enum kmemcheck_shadow state;
> -			/* Address and size of the erroneous read */
> -			unsigned long	address;
> -			unsigned int	size;
> -		};
> -	};
> -
> -	struct pt_regs		regs;
> -	struct stack_trace	trace;
> -	unsigned long		trace_entries[32];
> -
> -	/* We compress it to a char. */
> -	unsigned char		shadow_copy[SHADOW_COPY_SIZE];
> -	unsigned char		memory_copy[SHADOW_COPY_SIZE];
> -};
> -
> -/*
> - * Create a ring queue of errors to output. We can't call printk() directly
> - * from the kmemcheck traps, since this may call the console drivers and
> - * result in a recursive fault.
> - */
> -static struct kmemcheck_error error_fifo[CONFIG_KMEMCHECK_QUEUE_SIZE];
> -static unsigned int error_count;
> -static unsigned int error_rd;
> -static unsigned int error_wr;
> -static unsigned int error_missed_count;
> -
> -static struct kmemcheck_error *error_next_wr(void)
> -{
> -	struct kmemcheck_error *e;
> -
> -	if (error_count == ARRAY_SIZE(error_fifo)) {
> -		++error_missed_count;
> -		return NULL;
> -	}
> -
> -	e = &error_fifo[error_wr];
> -	if (++error_wr == ARRAY_SIZE(error_fifo))
> -		error_wr = 0;
> -	++error_count;
> -	return e;
> -}
> -
> -static struct kmemcheck_error *error_next_rd(void)
> -{
> -	struct kmemcheck_error *e;
> -
> -	if (error_count == 0)
> -		return NULL;
> -
> -	e = &error_fifo[error_rd];
> -	if (++error_rd == ARRAY_SIZE(error_fifo))
> -		error_rd = 0;
> -	--error_count;
> -	return e;
> -}
> -
> -void kmemcheck_error_recall(void)
> -{
> -	static const char *desc[] = {
> -		[KMEMCHECK_SHADOW_UNALLOCATED]		= "unallocated",
> -		[KMEMCHECK_SHADOW_UNINITIALIZED]	= "uninitialized",
> -		[KMEMCHECK_SHADOW_INITIALIZED]		= "initialized",
> -		[KMEMCHECK_SHADOW_FREED]		= "freed",
> -	};
> -
> -	static const char short_desc[] = {
> -		[KMEMCHECK_SHADOW_UNALLOCATED]		= 'a',
> -		[KMEMCHECK_SHADOW_UNINITIALIZED]	= 'u',
> -		[KMEMCHECK_SHADOW_INITIALIZED]		= 'i',
> -		[KMEMCHECK_SHADOW_FREED]		= 'f',
> -	};
> -
> -	struct kmemcheck_error *e;
> -	unsigned int i;
> -
> -	e = error_next_rd();
> -	if (!e)
> -		return;
> -
> -	switch (e->type) {
> -	case KMEMCHECK_ERROR_INVALID_ACCESS:
> -		printk(KERN_WARNING "WARNING: kmemcheck: Caught %d-bit read from %s memory (%p)\n",
> -			8 * e->size, e->state < ARRAY_SIZE(desc) ?
> -				desc[e->state] : "(invalid shadow state)",
> -			(void *) e->address);
> -
> -		printk(KERN_WARNING);
> -		for (i = 0; i < SHADOW_COPY_SIZE; ++i)
> -			printk(KERN_CONT "%02x", e->memory_copy[i]);
> -		printk(KERN_CONT "\n");
> -
> -		printk(KERN_WARNING);
> -		for (i = 0; i < SHADOW_COPY_SIZE; ++i) {
> -			if (e->shadow_copy[i] < ARRAY_SIZE(short_desc))
> -				printk(KERN_CONT " %c", short_desc[e->shadow_copy[i]]);
> -			else
> -				printk(KERN_CONT " ?");
> -		}
> -		printk(KERN_CONT "\n");
> -		printk(KERN_WARNING "%*c\n", 2 + 2
> -			* (int) (e->address & (SHADOW_COPY_SIZE - 1)), '^');
> -		break;
> -	case KMEMCHECK_ERROR_BUG:
> -		printk(KERN_EMERG "ERROR: kmemcheck: Fatal error\n");
> -		break;
> -	}
> -
> -	__show_regs(&e->regs, 1);
> -	print_stack_trace(&e->trace, 0);
> -}
> -
> -static void do_wakeup(unsigned long data)
> -{
> -	while (error_count > 0)
> -		kmemcheck_error_recall();
> -
> -	if (error_missed_count > 0) {
> -		printk(KERN_WARNING "kmemcheck: Lost %d error reports because "
> -			"the queue was too small\n", error_missed_count);
> -		error_missed_count = 0;
> -	}
> -}
> -
> -static DECLARE_TASKLET(kmemcheck_tasklet, &do_wakeup, 0);
> -
> -/*
> - * Save the context of an error report.
> - */
> -void kmemcheck_error_save(enum kmemcheck_shadow state,
> -	unsigned long address, unsigned int size, struct pt_regs *regs)
> -{
> -	static unsigned long prev_ip;
> -
> -	struct kmemcheck_error *e;
> -	void *shadow_copy;
> -	void *memory_copy;
> -
> -	/* Don't report several adjacent errors from the same EIP. */
> -	if (regs->ip == prev_ip)
> -		return;
> -	prev_ip = regs->ip;
> -
> -	e = error_next_wr();
> -	if (!e)
> -		return;
> -
> -	e->type = KMEMCHECK_ERROR_INVALID_ACCESS;
> -
> -	e->state = state;
> -	e->address = address;
> -	e->size = size;
> -
> -	/* Save regs */
> -	memcpy(&e->regs, regs, sizeof(*regs));
> -
> -	/* Save stack trace */
> -	e->trace.nr_entries = 0;
> -	e->trace.entries = e->trace_entries;
> -	e->trace.max_entries = ARRAY_SIZE(e->trace_entries);
> -	e->trace.skip = 0;
> -	save_stack_trace_regs(regs, &e->trace);
> -
> -	/* Round address down to nearest 16 bytes */
> -	shadow_copy = kmemcheck_shadow_lookup(address
> -		& ~(SHADOW_COPY_SIZE - 1));
> -	BUG_ON(!shadow_copy);
> -
> -	memcpy(e->shadow_copy, shadow_copy, SHADOW_COPY_SIZE);
> -
> -	kmemcheck_show_addr(address);
> -	memory_copy = (void *) (address & ~(SHADOW_COPY_SIZE - 1));
> -	memcpy(e->memory_copy, memory_copy, SHADOW_COPY_SIZE);
> -	kmemcheck_hide_addr(address);
> -
> -	tasklet_hi_schedule_first(&kmemcheck_tasklet);
> -}
> -
> -/*
> - * Save the context of a kmemcheck bug.
> - */
> -void kmemcheck_error_save_bug(struct pt_regs *regs)
> -{
> -	struct kmemcheck_error *e;
> -
> -	e = error_next_wr();
> -	if (!e)
> -		return;
> -
> -	e->type = KMEMCHECK_ERROR_BUG;
> -
> -	memcpy(&e->regs, regs, sizeof(*regs));
> -
> -	e->trace.nr_entries = 0;
> -	e->trace.entries = e->trace_entries;
> -	e->trace.max_entries = ARRAY_SIZE(e->trace_entries);
> -	e->trace.skip = 1;
> -	save_stack_trace(&e->trace);
> -
> -	tasklet_hi_schedule_first(&kmemcheck_tasklet);
> -}
> diff --git a/arch/x86/mm/kmemcheck/error.h b/arch/x86/mm/kmemcheck/error.h
> deleted file mode 100644
> index 0efc2e8..0000000
> --- a/arch/x86/mm/kmemcheck/error.h
> +++ /dev/null
> @@ -1,15 +0,0 @@
> -#ifndef ARCH__X86__MM__KMEMCHECK__ERROR_H
> -#define ARCH__X86__MM__KMEMCHECK__ERROR_H
> -
> -#include <linux/ptrace.h>
> -
> -#include "shadow.h"
> -
> -void kmemcheck_error_save(enum kmemcheck_shadow state,
> -	unsigned long address, unsigned int size, struct pt_regs *regs);
> -
> -void kmemcheck_error_save_bug(struct pt_regs *regs);
> -
> -void kmemcheck_error_recall(void);
> -
> -#endif
> diff --git a/arch/x86/mm/kmemcheck/kmemcheck.c b/arch/x86/mm/kmemcheck/kmemcheck.c
> deleted file mode 100644
> index b4f2e7e..0000000
> --- a/arch/x86/mm/kmemcheck/kmemcheck.c
> +++ /dev/null
> @@ -1,659 +0,0 @@
> -/**
> - * kmemcheck - a heavyweight memory checker for the linux kernel
> - * Copyright (C) 2007, 2008  Vegard Nossum <vegardno@ifi.uio.no>
> - * (With a lot of help from Ingo Molnar and Pekka Enberg.)
> - *
> - * This program is free software; you can redistribute it and/or modify
> - * it under the terms of the GNU General Public License (version 2) as
> - * published by the Free Software Foundation.
> - */
> -
> -#include <linux/init.h>
> -#include <linux/interrupt.h>
> -#include <linux/kallsyms.h>
> -#include <linux/kernel.h>
> -#include <linux/kmemcheck.h>
> -#include <linux/mm.h>
> -#include <linux/module.h>
> -#include <linux/page-flags.h>
> -#include <linux/percpu.h>
> -#include <linux/ptrace.h>
> -#include <linux/string.h>
> -#include <linux/types.h>
> -
> -#include <asm/cacheflush.h>
> -#include <asm/kmemcheck.h>
> -#include <asm/pgtable.h>
> -#include <asm/tlbflush.h>
> -
> -#include "error.h"
> -#include "opcode.h"
> -#include "pte.h"
> -#include "selftest.h"
> -#include "shadow.h"
> -
> -
> -#ifdef CONFIG_KMEMCHECK_DISABLED_BY_DEFAULT
> -#  define KMEMCHECK_ENABLED 0
> -#endif
> -
> -#ifdef CONFIG_KMEMCHECK_ENABLED_BY_DEFAULT
> -#  define KMEMCHECK_ENABLED 1
> -#endif
> -
> -#ifdef CONFIG_KMEMCHECK_ONESHOT_BY_DEFAULT
> -#  define KMEMCHECK_ENABLED 2
> -#endif
> -
> -int kmemcheck_enabled = KMEMCHECK_ENABLED;
> -
> -int __init kmemcheck_init(void)
> -{
> -#ifdef CONFIG_SMP
> -	/*
> -	 * Limit SMP to use a single CPU. We rely on the fact that this code
> -	 * runs before SMP is set up.
> -	 */
> -	if (setup_max_cpus > 1) {
> -		printk(KERN_INFO
> -			"kmemcheck: Limiting number of CPUs to 1.\n");
> -		setup_max_cpus = 1;
> -	}
> -#endif
> -
> -	if (!kmemcheck_selftest()) {
> -		printk(KERN_INFO "kmemcheck: self-tests failed; disabling\n");
> -		kmemcheck_enabled = 0;
> -		return -EINVAL;
> -	}
> -
> -	printk(KERN_INFO "kmemcheck: Initialized\n");
> -	return 0;
> -}
> -
> -early_initcall(kmemcheck_init);
> -
> -/*
> - * We need to parse the kmemcheck= option before any memory is allocated.
> - */
> -static int __init param_kmemcheck(char *str)
> -{
> -	int val;
> -	int ret;
> -
> -	if (!str)
> -		return -EINVAL;
> -
> -	ret = kstrtoint(str, 0, &val);
> -	if (ret)
> -		return ret;
> -	kmemcheck_enabled = val;
> -	return 0;
> -}
> -
> -early_param("kmemcheck", param_kmemcheck);
> -
> -int kmemcheck_show_addr(unsigned long address)
> -{
> -	pte_t *pte;
> -
> -	pte = kmemcheck_pte_lookup(address);
> -	if (!pte)
> -		return 0;
> -
> -	set_pte(pte, __pte(pte_val(*pte) | _PAGE_PRESENT));
> -	__flush_tlb_one(address);
> -	return 1;
> -}
> -
> -int kmemcheck_hide_addr(unsigned long address)
> -{
> -	pte_t *pte;
> -
> -	pte = kmemcheck_pte_lookup(address);
> -	if (!pte)
> -		return 0;
> -
> -	set_pte(pte, __pte(pte_val(*pte) & ~_PAGE_PRESENT));
> -	__flush_tlb_one(address);
> -	return 1;
> -}
> -
> -struct kmemcheck_context {
> -	bool busy;
> -	int balance;
> -
> -	/*
> -	 * There can be at most two memory operands to an instruction, but
> -	 * each address can cross a page boundary -- so we may need up to
> -	 * four addresses that must be hidden/revealed for each fault.
> -	 */
> -	unsigned long addr[4];
> -	unsigned long n_addrs;
> -	unsigned long flags;
> -
> -	/* Data size of the instruction that caused a fault. */
> -	unsigned int size;
> -};
> -
> -static DEFINE_PER_CPU(struct kmemcheck_context, kmemcheck_context);
> -
> -bool kmemcheck_active(struct pt_regs *regs)
> -{
> -	struct kmemcheck_context *data = this_cpu_ptr(&kmemcheck_context);
> -
> -	return data->balance > 0;
> -}
> -
> -/* Save an address that needs to be shown/hidden */
> -static void kmemcheck_save_addr(unsigned long addr)
> -{
> -	struct kmemcheck_context *data = this_cpu_ptr(&kmemcheck_context);
> -
> -	BUG_ON(data->n_addrs >= ARRAY_SIZE(data->addr));
> -	data->addr[data->n_addrs++] = addr;
> -}
> -
> -static unsigned int kmemcheck_show_all(void)
> -{
> -	struct kmemcheck_context *data = this_cpu_ptr(&kmemcheck_context);
> -	unsigned int i;
> -	unsigned int n;
> -
> -	n = 0;
> -	for (i = 0; i < data->n_addrs; ++i)
> -		n += kmemcheck_show_addr(data->addr[i]);
> -
> -	return n;
> -}
> -
> -static unsigned int kmemcheck_hide_all(void)
> -{
> -	struct kmemcheck_context *data = this_cpu_ptr(&kmemcheck_context);
> -	unsigned int i;
> -	unsigned int n;
> -
> -	n = 0;
> -	for (i = 0; i < data->n_addrs; ++i)
> -		n += kmemcheck_hide_addr(data->addr[i]);
> -
> -	return n;
> -}
> -
> -/*
> - * Called from the #PF handler.
> - */
> -void kmemcheck_show(struct pt_regs *regs)
> -{
> -	struct kmemcheck_context *data = this_cpu_ptr(&kmemcheck_context);
> -
> -	BUG_ON(!irqs_disabled());
> -
> -	if (unlikely(data->balance != 0)) {
> -		kmemcheck_show_all();
> -		kmemcheck_error_save_bug(regs);
> -		data->balance = 0;
> -		return;
> -	}
> -
> -	/*
> -	 * None of the addresses actually belonged to kmemcheck. Note that
> -	 * this is not an error.
> -	 */
> -	if (kmemcheck_show_all() == 0)
> -		return;
> -
> -	++data->balance;
> -
> -	/*
> -	 * The IF needs to be cleared as well, so that the faulting
> -	 * instruction can run "uninterrupted". Otherwise, we might take
> -	 * an interrupt and start executing that before we've had a chance
> -	 * to hide the page again.
> -	 *
> -	 * NOTE: In the rare case of multiple faults, we must not override
> -	 * the original flags:
> -	 */
> -	if (!(regs->flags & X86_EFLAGS_TF))
> -		data->flags = regs->flags;
> -
> -	regs->flags |= X86_EFLAGS_TF;
> -	regs->flags &= ~X86_EFLAGS_IF;
> -}
> -
> -/*
> - * Called from the #DB handler.
> - */
> -void kmemcheck_hide(struct pt_regs *regs)
> -{
> -	struct kmemcheck_context *data = this_cpu_ptr(&kmemcheck_context);
> -	int n;
> -
> -	BUG_ON(!irqs_disabled());
> -
> -	if (unlikely(data->balance != 1)) {
> -		kmemcheck_show_all();
> -		kmemcheck_error_save_bug(regs);
> -		data->n_addrs = 0;
> -		data->balance = 0;
> -
> -		if (!(data->flags & X86_EFLAGS_TF))
> -			regs->flags &= ~X86_EFLAGS_TF;
> -		if (data->flags & X86_EFLAGS_IF)
> -			regs->flags |= X86_EFLAGS_IF;
> -		return;
> -	}
> -
> -	if (kmemcheck_enabled)
> -		n = kmemcheck_hide_all();
> -	else
> -		n = kmemcheck_show_all();
> -
> -	if (n == 0)
> -		return;
> -
> -	--data->balance;
> -
> -	data->n_addrs = 0;
> -
> -	if (!(data->flags & X86_EFLAGS_TF))
> -		regs->flags &= ~X86_EFLAGS_TF;
> -	if (data->flags & X86_EFLAGS_IF)
> -		regs->flags |= X86_EFLAGS_IF;
> -}
> -
> -void kmemcheck_show_pages(struct page *p, unsigned int n)
> -{
> -	unsigned int i;
> -
> -	for (i = 0; i < n; ++i) {
> -		unsigned long address;
> -		pte_t *pte;
> -		unsigned int level;
> -
> -		address = (unsigned long) page_address(&p[i]);
> -		pte = lookup_address(address, &level);
> -		BUG_ON(!pte);
> -		BUG_ON(level != PG_LEVEL_4K);
> -
> -		set_pte(pte, __pte(pte_val(*pte) | _PAGE_PRESENT));
> -		set_pte(pte, __pte(pte_val(*pte) & ~_PAGE_HIDDEN));
> -		__flush_tlb_one(address);
> -	}
> -}
> -
> -bool kmemcheck_page_is_tracked(struct page *p)
> -{
> -	/* This will also check the "hidden" flag of the PTE. */
> -	return kmemcheck_pte_lookup((unsigned long) page_address(p));
> -}
> -
> -void kmemcheck_hide_pages(struct page *p, unsigned int n)
> -{
> -	unsigned int i;
> -
> -	for (i = 0; i < n; ++i) {
> -		unsigned long address;
> -		pte_t *pte;
> -		unsigned int level;
> -
> -		address = (unsigned long) page_address(&p[i]);
> -		pte = lookup_address(address, &level);
> -		BUG_ON(!pte);
> -		BUG_ON(level != PG_LEVEL_4K);
> -
> -		set_pte(pte, __pte(pte_val(*pte) & ~_PAGE_PRESENT));
> -		set_pte(pte, __pte(pte_val(*pte) | _PAGE_HIDDEN));
> -		__flush_tlb_one(address);
> -	}
> -}
> -
> -/* Access may NOT cross page boundary */
> -static void kmemcheck_read_strict(struct pt_regs *regs,
> -	unsigned long addr, unsigned int size)
> -{
> -	void *shadow;
> -	enum kmemcheck_shadow status;
> -
> -	shadow = kmemcheck_shadow_lookup(addr);
> -	if (!shadow)
> -		return;
> -
> -	kmemcheck_save_addr(addr);
> -	status = kmemcheck_shadow_test(shadow, size);
> -	if (status == KMEMCHECK_SHADOW_INITIALIZED)
> -		return;
> -
> -	if (kmemcheck_enabled)
> -		kmemcheck_error_save(status, addr, size, regs);
> -
> -	if (kmemcheck_enabled == 2)
> -		kmemcheck_enabled = 0;
> -
> -	/* Don't warn about it again. */
> -	kmemcheck_shadow_set(shadow, size);
> -}
> -
> -bool kmemcheck_is_obj_initialized(unsigned long addr, size_t size)
> -{
> -	enum kmemcheck_shadow status;
> -	void *shadow;
> -
> -	shadow = kmemcheck_shadow_lookup(addr);
> -	if (!shadow)
> -		return true;
> -
> -	status = kmemcheck_shadow_test_all(shadow, size);
> -
> -	return status == KMEMCHECK_SHADOW_INITIALIZED;
> -}
> -
> -/* Access may cross page boundary */
> -static void kmemcheck_read(struct pt_regs *regs,
> -	unsigned long addr, unsigned int size)
> -{
> -	unsigned long page = addr & PAGE_MASK;
> -	unsigned long next_addr = addr + size - 1;
> -	unsigned long next_page = next_addr & PAGE_MASK;
> -
> -	if (likely(page == next_page)) {
> -		kmemcheck_read_strict(regs, addr, size);
> -		return;
> -	}
> -
> -	/*
> -	 * What we do is basically to split the access across the
> -	 * two pages and handle each part separately. Yes, this means
> -	 * that we may now see reads that are 3 + 5 bytes, for
> -	 * example (and if both are uninitialized, there will be two
> -	 * reports), but it makes the code a lot simpler.
> -	 */
> -	kmemcheck_read_strict(regs, addr, next_page - addr);
> -	kmemcheck_read_strict(regs, next_page, next_addr - next_page);
> -}
> -
> -static void kmemcheck_write_strict(struct pt_regs *regs,
> -	unsigned long addr, unsigned int size)
> -{
> -	void *shadow;
> -
> -	shadow = kmemcheck_shadow_lookup(addr);
> -	if (!shadow)
> -		return;
> -
> -	kmemcheck_save_addr(addr);
> -	kmemcheck_shadow_set(shadow, size);
> -}
> -
> -static void kmemcheck_write(struct pt_regs *regs,
> -	unsigned long addr, unsigned int size)
> -{
> -	unsigned long page = addr & PAGE_MASK;
> -	unsigned long next_addr = addr + size - 1;
> -	unsigned long next_page = next_addr & PAGE_MASK;
> -
> -	if (likely(page == next_page)) {
> -		kmemcheck_write_strict(regs, addr, size);
> -		return;
> -	}
> -
> -	/* See comment in kmemcheck_read(). */
> -	kmemcheck_write_strict(regs, addr, next_page - addr);
> -	kmemcheck_write_strict(regs, next_page, next_addr - next_page);
> -}
> -
> -/*
> - * Copying is hard. We have two addresses, each of which may be split across
> - * a page (and each page will have different shadow addresses).
> - */
> -static void kmemcheck_copy(struct pt_regs *regs,
> -	unsigned long src_addr, unsigned long dst_addr, unsigned int size)
> -{
> -	uint8_t shadow[8];
> -	enum kmemcheck_shadow status;
> -
> -	unsigned long page;
> -	unsigned long next_addr;
> -	unsigned long next_page;
> -
> -	uint8_t *x;
> -	unsigned int i;
> -	unsigned int n;
> -
> -	BUG_ON(size > sizeof(shadow));
> -
> -	page = src_addr & PAGE_MASK;
> -	next_addr = src_addr + size - 1;
> -	next_page = next_addr & PAGE_MASK;
> -
> -	if (likely(page == next_page)) {
> -		/* Same page */
> -		x = kmemcheck_shadow_lookup(src_addr);
> -		if (x) {
> -			kmemcheck_save_addr(src_addr);
> -			for (i = 0; i < size; ++i)
> -				shadow[i] = x[i];
> -		} else {
> -			for (i = 0; i < size; ++i)
> -				shadow[i] = KMEMCHECK_SHADOW_INITIALIZED;
> -		}
> -	} else {
> -		n = next_page - src_addr;
> -		BUG_ON(n > sizeof(shadow));
> -
> -		/* First page */
> -		x = kmemcheck_shadow_lookup(src_addr);
> -		if (x) {
> -			kmemcheck_save_addr(src_addr);
> -			for (i = 0; i < n; ++i)
> -				shadow[i] = x[i];
> -		} else {
> -			/* Not tracked */
> -			for (i = 0; i < n; ++i)
> -				shadow[i] = KMEMCHECK_SHADOW_INITIALIZED;
> -		}
> -
> -		/* Second page */
> -		x = kmemcheck_shadow_lookup(next_page);
> -		if (x) {
> -			kmemcheck_save_addr(next_page);
> -			for (i = n; i < size; ++i)
> -				shadow[i] = x[i - n];
> -		} else {
> -			/* Not tracked */
> -			for (i = n; i < size; ++i)
> -				shadow[i] = KMEMCHECK_SHADOW_INITIALIZED;
> -		}
> -	}
> -
> -	page = dst_addr & PAGE_MASK;
> -	next_addr = dst_addr + size - 1;
> -	next_page = next_addr & PAGE_MASK;
> -
> -	if (likely(page == next_page)) {
> -		/* Same page */
> -		x = kmemcheck_shadow_lookup(dst_addr);
> -		if (x) {
> -			kmemcheck_save_addr(dst_addr);
> -			for (i = 0; i < size; ++i) {
> -				x[i] = shadow[i];
> -				shadow[i] = KMEMCHECK_SHADOW_INITIALIZED;
> -			}
> -		}
> -	} else {
> -		n = next_page - dst_addr;
> -		BUG_ON(n > sizeof(shadow));
> -
> -		/* First page */
> -		x = kmemcheck_shadow_lookup(dst_addr);
> -		if (x) {
> -			kmemcheck_save_addr(dst_addr);
> -			for (i = 0; i < n; ++i) {
> -				x[i] = shadow[i];
> -				shadow[i] = KMEMCHECK_SHADOW_INITIALIZED;
> -			}
> -		}
> -
> -		/* Second page */
> -		x = kmemcheck_shadow_lookup(next_page);
> -		if (x) {
> -			kmemcheck_save_addr(next_page);
> -			for (i = n; i < size; ++i) {
> -				x[i - n] = shadow[i];
> -				shadow[i] = KMEMCHECK_SHADOW_INITIALIZED;
> -			}
> -		}
> -	}
> -
> -	status = kmemcheck_shadow_test(shadow, size);
> -	if (status == KMEMCHECK_SHADOW_INITIALIZED)
> -		return;
> -
> -	if (kmemcheck_enabled)
> -		kmemcheck_error_save(status, src_addr, size, regs);
> -
> -	if (kmemcheck_enabled == 2)
> -		kmemcheck_enabled = 0;
> -}
> -
> -enum kmemcheck_method {
> -	KMEMCHECK_READ,
> -	KMEMCHECK_WRITE,
> -};
> -
> -static void kmemcheck_access(struct pt_regs *regs,
> -	unsigned long fallback_address, enum kmemcheck_method fallback_method)
> -{
> -	const uint8_t *insn;
> -	const uint8_t *insn_primary;
> -	unsigned int size;
> -
> -	struct kmemcheck_context *data = this_cpu_ptr(&kmemcheck_context);
> -
> -	/* Recursive fault -- ouch. */
> -	if (data->busy) {
> -		kmemcheck_show_addr(fallback_address);
> -		kmemcheck_error_save_bug(regs);
> -		return;
> -	}
> -
> -	data->busy = true;
> -
> -	insn = (const uint8_t *) regs->ip;
> -	insn_primary = kmemcheck_opcode_get_primary(insn);
> -
> -	kmemcheck_opcode_decode(insn, &size);
> -
> -	switch (insn_primary[0]) {
> -#ifdef CONFIG_KMEMCHECK_BITOPS_OK
> -		/* AND, OR, XOR */
> -		/*
> -		 * Unfortunately, these instructions have to be excluded from
> -		 * our regular checking since they access only some (and not
> -		 * all) bits. This clears out "bogus" bitfield-access warnings.
> -		 */
> -	case 0x80:
> -	case 0x81:
> -	case 0x82:
> -	case 0x83:
> -		switch ((insn_primary[1] >> 3) & 7) {
> -			/* OR */
> -		case 1:
> -			/* AND */
> -		case 4:
> -			/* XOR */
> -		case 6:
> -			kmemcheck_write(regs, fallback_address, size);
> -			goto out;
> -
> -			/* ADD */
> -		case 0:
> -			/* ADC */
> -		case 2:
> -			/* SBB */
> -		case 3:
> -			/* SUB */
> -		case 5:
> -			/* CMP */
> -		case 7:
> -			break;
> -		}
> -		break;
> -#endif
> -
> -		/* MOVS, MOVSB, MOVSW, MOVSD */
> -	case 0xa4:
> -	case 0xa5:
> -		/*
> -		 * These instructions are special because they take two
> -		 * addresses, but we only get one page fault.
> -		 */
> -		kmemcheck_copy(regs, regs->si, regs->di, size);
> -		goto out;
> -
> -		/* CMPS, CMPSB, CMPSW, CMPSD */
> -	case 0xa6:
> -	case 0xa7:
> -		kmemcheck_read(regs, regs->si, size);
> -		kmemcheck_read(regs, regs->di, size);
> -		goto out;
> -	}
> -
> -	/*
> -	 * If the opcode isn't special in any way, we use the data from the
> -	 * page fault handler to determine the address and type of memory
> -	 * access.
> -	 */
> -	switch (fallback_method) {
> -	case KMEMCHECK_READ:
> -		kmemcheck_read(regs, fallback_address, size);
> -		goto out;
> -	case KMEMCHECK_WRITE:
> -		kmemcheck_write(regs, fallback_address, size);
> -		goto out;
> -	}
> -
> -out:
> -	data->busy = false;
> -}
> -
> -bool kmemcheck_fault(struct pt_regs *regs, unsigned long address,
> -	unsigned long error_code)
> -{
> -	pte_t *pte;
> -
> -	/*
> -	 * XXX: Is it safe to assume that memory accesses from virtual 86
> -	 * mode or non-kernel code segments will _never_ access kernel
> -	 * memory (e.g. tracked pages)? For now, we need this to avoid
> -	 * invoking kmemcheck for PnP BIOS calls.
> -	 */
> -	if (regs->flags & X86_VM_MASK)
> -		return false;
> -	if (regs->cs != __KERNEL_CS)
> -		return false;
> -
> -	pte = kmemcheck_pte_lookup(address);
> -	if (!pte)
> -		return false;
> -
> -	WARN_ON_ONCE(in_nmi());
> -
> -	if (error_code & 2)
> -		kmemcheck_access(regs, address, KMEMCHECK_WRITE);
> -	else
> -		kmemcheck_access(regs, address, KMEMCHECK_READ);
> -
> -	kmemcheck_show(regs);
> -	return true;
> -}
> -
> -bool kmemcheck_trap(struct pt_regs *regs)
> -{
> -	if (!kmemcheck_active(regs))
> -		return false;
> -
> -	/* We're done. */
> -	kmemcheck_hide(regs);
> -	return true;
> -}
> diff --git a/arch/x86/mm/kmemcheck/opcode.c b/arch/x86/mm/kmemcheck/opcode.c
> deleted file mode 100644
> index 324aa3f..0000000
> --- a/arch/x86/mm/kmemcheck/opcode.c
> +++ /dev/null
> @@ -1,106 +0,0 @@
> -#include <linux/types.h>
> -
> -#include "opcode.h"
> -
> -static bool opcode_is_prefix(uint8_t b)
> -{
> -	return
> -		/* Group 1 */
> -		b == 0xf0 || b == 0xf2 || b == 0xf3
> -		/* Group 2 */
> -		|| b == 0x2e || b == 0x36 || b == 0x3e || b == 0x26
> -		|| b == 0x64 || b == 0x65
> -		/* Group 3 */
> -		|| b == 0x66
> -		/* Group 4 */
> -		|| b == 0x67;
> -}
> -
> -#ifdef CONFIG_X86_64
> -static bool opcode_is_rex_prefix(uint8_t b)
> -{
> -	return (b & 0xf0) == 0x40;
> -}
> -#else
> -static bool opcode_is_rex_prefix(uint8_t b)
> -{
> -	return false;
> -}
> -#endif
> -
> -#define REX_W (1 << 3)
> -
> -/*
> - * This is a VERY crude opcode decoder. We only need to find the size of the
> - * load/store that caused our #PF and this should work for all the opcodes
> - * that we care about. Moreover, the ones who invented this instruction set
> - * should be shot.
> - */
> -void kmemcheck_opcode_decode(const uint8_t *op, unsigned int *size)
> -{
> -	/* Default operand size */
> -	int operand_size_override = 4;
> -
> -	/* prefixes */
> -	for (; opcode_is_prefix(*op); ++op) {
> -		if (*op == 0x66)
> -			operand_size_override = 2;
> -	}
> -
> -	/* REX prefix */
> -	if (opcode_is_rex_prefix(*op)) {
> -		uint8_t rex = *op;
> -
> -		++op;
> -		if (rex & REX_W) {
> -			switch (*op) {
> -			case 0x63:
> -				*size = 4;
> -				return;
> -			case 0x0f:
> -				++op;
> -
> -				switch (*op) {
> -				case 0xb6:
> -				case 0xbe:
> -					*size = 1;
> -					return;
> -				case 0xb7:
> -				case 0xbf:
> -					*size = 2;
> -					return;
> -				}
> -
> -				break;
> -			}
> -
> -			*size = 8;
> -			return;
> -		}
> -	}
> -
> -	/* escape opcode */
> -	if (*op == 0x0f) {
> -		++op;
> -
> -		/*
> -		 * This is move with zero-extend and sign-extend, respectively;
> -		 * we don't have to think about 0xb6/0xbe, because this is
> -		 * already handled in the conditional below.
> -		 */
> -		if (*op == 0xb7 || *op == 0xbf)
> -			operand_size_override = 2;
> -	}
> -
> -	*size = (*op & 1) ? operand_size_override : 1;
> -}
> -
> -const uint8_t *kmemcheck_opcode_get_primary(const uint8_t *op)
> -{
> -	/* skip prefixes */
> -	while (opcode_is_prefix(*op))
> -		++op;
> -	if (opcode_is_rex_prefix(*op))
> -		++op;
> -	return op;
> -}
> diff --git a/arch/x86/mm/kmemcheck/opcode.h b/arch/x86/mm/kmemcheck/opcode.h
> deleted file mode 100644
> index 6956aad..0000000
> --- a/arch/x86/mm/kmemcheck/opcode.h
> +++ /dev/null
> @@ -1,9 +0,0 @@
> -#ifndef ARCH__X86__MM__KMEMCHECK__OPCODE_H
> -#define ARCH__X86__MM__KMEMCHECK__OPCODE_H
> -
> -#include <linux/types.h>
> -
> -void kmemcheck_opcode_decode(const uint8_t *op, unsigned int *size);
> -const uint8_t *kmemcheck_opcode_get_primary(const uint8_t *op);
> -
> -#endif
> diff --git a/arch/x86/mm/kmemcheck/pte.c b/arch/x86/mm/kmemcheck/pte.c
> deleted file mode 100644
> index 4ead26e..0000000
> --- a/arch/x86/mm/kmemcheck/pte.c
> +++ /dev/null
> @@ -1,22 +0,0 @@
> -#include <linux/mm.h>
> -
> -#include <asm/pgtable.h>
> -
> -#include "pte.h"
> -
> -pte_t *kmemcheck_pte_lookup(unsigned long address)
> -{
> -	pte_t *pte;
> -	unsigned int level;
> -
> -	pte = lookup_address(address, &level);
> -	if (!pte)
> -		return NULL;
> -	if (level != PG_LEVEL_4K)
> -		return NULL;
> -	if (!pte_hidden(*pte))
> -		return NULL;
> -
> -	return pte;
> -}
> -
> diff --git a/arch/x86/mm/kmemcheck/pte.h b/arch/x86/mm/kmemcheck/pte.h
> deleted file mode 100644
> index 9f59664..0000000
> --- a/arch/x86/mm/kmemcheck/pte.h
> +++ /dev/null
> @@ -1,10 +0,0 @@
> -#ifndef ARCH__X86__MM__KMEMCHECK__PTE_H
> -#define ARCH__X86__MM__KMEMCHECK__PTE_H
> -
> -#include <linux/mm.h>
> -
> -#include <asm/pgtable.h>
> -
> -pte_t *kmemcheck_pte_lookup(unsigned long address);
> -
> -#endif
> diff --git a/arch/x86/mm/kmemcheck/selftest.c b/arch/x86/mm/kmemcheck/selftest.c
> deleted file mode 100644
> index aef7140..0000000
> --- a/arch/x86/mm/kmemcheck/selftest.c
> +++ /dev/null
> @@ -1,70 +0,0 @@
> -#include <linux/bug.h>
> -#include <linux/kernel.h>
> -
> -#include "opcode.h"
> -#include "selftest.h"
> -
> -struct selftest_opcode {
> -	unsigned int expected_size;
> -	const uint8_t *insn;
> -	const char *desc;
> -};
> -
> -static const struct selftest_opcode selftest_opcodes[] = {
> -	/* REP MOVS */
> -	{1, "\xf3\xa4", 		"rep movsb <mem8>, <mem8>"},
> -	{4, "\xf3\xa5",			"rep movsl <mem32>, <mem32>"},
> -
> -	/* MOVZX / MOVZXD */
> -	{1, "\x66\x0f\xb6\x51\xf8",	"movzwq <mem8>, <reg16>"},
> -	{1, "\x0f\xb6\x51\xf8",		"movzwq <mem8>, <reg32>"},
> -
> -	/* MOVSX / MOVSXD */
> -	{1, "\x66\x0f\xbe\x51\xf8",	"movswq <mem8>, <reg16>"},
> -	{1, "\x0f\xbe\x51\xf8",		"movswq <mem8>, <reg32>"},
> -
> -#ifdef CONFIG_X86_64
> -	/* MOVZX / MOVZXD */
> -	{1, "\x49\x0f\xb6\x51\xf8",	"movzbq <mem8>, <reg64>"},
> -	{2, "\x49\x0f\xb7\x51\xf8",	"movzbq <mem16>, <reg64>"},
> -
> -	/* MOVSX / MOVSXD */
> -	{1, "\x49\x0f\xbe\x51\xf8",	"movsbq <mem8>, <reg64>"},
> -	{2, "\x49\x0f\xbf\x51\xf8",	"movsbq <mem16>, <reg64>"},
> -	{4, "\x49\x63\x51\xf8",		"movslq <mem32>, <reg64>"},
> -#endif
> -};
> -
> -static bool selftest_opcode_one(const struct selftest_opcode *op)
> -{
> -	unsigned size;
> -
> -	kmemcheck_opcode_decode(op->insn, &size);
> -
> -	if (size == op->expected_size)
> -		return true;
> -
> -	printk(KERN_WARNING "kmemcheck: opcode %s: expected size %d, got %d\n",
> -		op->desc, op->expected_size, size);
> -	return false;
> -}
> -
> -static bool selftest_opcodes_all(void)
> -{
> -	bool pass = true;
> -	unsigned int i;
> -
> -	for (i = 0; i < ARRAY_SIZE(selftest_opcodes); ++i)
> -		pass = pass && selftest_opcode_one(&selftest_opcodes[i]);
> -
> -	return pass;
> -}
> -
> -bool kmemcheck_selftest(void)
> -{
> -	bool pass = true;
> -
> -	pass = pass && selftest_opcodes_all();
> -
> -	return pass;
> -}
> diff --git a/arch/x86/mm/kmemcheck/selftest.h b/arch/x86/mm/kmemcheck/selftest.h
> deleted file mode 100644
> index 8fed4fe..0000000
> --- a/arch/x86/mm/kmemcheck/selftest.h
> +++ /dev/null
> @@ -1,6 +0,0 @@
> -#ifndef ARCH_X86_MM_KMEMCHECK_SELFTEST_H
> -#define ARCH_X86_MM_KMEMCHECK_SELFTEST_H
> -
> -bool kmemcheck_selftest(void);
> -
> -#endif
> diff --git a/arch/x86/mm/kmemcheck/shadow.c b/arch/x86/mm/kmemcheck/shadow.c
> deleted file mode 100644
> index aec1242..0000000
> --- a/arch/x86/mm/kmemcheck/shadow.c
> +++ /dev/null
> @@ -1,173 +0,0 @@
> -#include <linux/kmemcheck.h>
> -#include <linux/module.h>
> -#include <linux/mm.h>
> -
> -#include <asm/page.h>
> -#include <asm/pgtable.h>
> -
> -#include "pte.h"
> -#include "shadow.h"
> -
> -/*
> - * Return the shadow address for the given address. Returns NULL if the
> - * address is not tracked.
> - *
> - * We need to be extremely careful not to follow any invalid pointers,
> - * because this function can be called for *any* possible address.
> - */
> -void *kmemcheck_shadow_lookup(unsigned long address)
> -{
> -	pte_t *pte;
> -	struct page *page;
> -
> -	if (!virt_addr_valid(address))
> -		return NULL;
> -
> -	pte = kmemcheck_pte_lookup(address);
> -	if (!pte)
> -		return NULL;
> -
> -	page = virt_to_page(address);
> -	if (!page->shadow)
> -		return NULL;
> -	return page->shadow + (address & (PAGE_SIZE - 1));
> -}
> -
> -static void mark_shadow(void *address, unsigned int n,
> -	enum kmemcheck_shadow status)
> -{
> -	unsigned long addr = (unsigned long) address;
> -	unsigned long last_addr = addr + n - 1;
> -	unsigned long page = addr & PAGE_MASK;
> -	unsigned long last_page = last_addr & PAGE_MASK;
> -	unsigned int first_n;
> -	void *shadow;
> -
> -	/* If the memory range crosses a page boundary, stop there. */
> -	if (page == last_page)
> -		first_n = n;
> -	else
> -		first_n = page + PAGE_SIZE - addr;
> -
> -	shadow = kmemcheck_shadow_lookup(addr);
> -	if (shadow)
> -		memset(shadow, status, first_n);
> -
> -	addr += first_n;
> -	n -= first_n;
> -
> -	/* Do full-page memset()s. */
> -	while (n >= PAGE_SIZE) {
> -		shadow = kmemcheck_shadow_lookup(addr);
> -		if (shadow)
> -			memset(shadow, status, PAGE_SIZE);
> -
> -		addr += PAGE_SIZE;
> -		n -= PAGE_SIZE;
> -	}
> -
> -	/* Do the remaining page, if any. */
> -	if (n > 0) {
> -		shadow = kmemcheck_shadow_lookup(addr);
> -		if (shadow)
> -			memset(shadow, status, n);
> -	}
> -}
> -
> -void kmemcheck_mark_unallocated(void *address, unsigned int n)
> -{
> -	mark_shadow(address, n, KMEMCHECK_SHADOW_UNALLOCATED);
> -}
> -
> -void kmemcheck_mark_uninitialized(void *address, unsigned int n)
> -{
> -	mark_shadow(address, n, KMEMCHECK_SHADOW_UNINITIALIZED);
> -}
> -
> -/*
> - * Fill the shadow memory of the given address such that the memory at that
> - * address is marked as being initialized.
> - */
> -void kmemcheck_mark_initialized(void *address, unsigned int n)
> -{
> -	mark_shadow(address, n, KMEMCHECK_SHADOW_INITIALIZED);
> -}
> -EXPORT_SYMBOL_GPL(kmemcheck_mark_initialized);
> -
> -void kmemcheck_mark_freed(void *address, unsigned int n)
> -{
> -	mark_shadow(address, n, KMEMCHECK_SHADOW_FREED);
> -}
> -
> -void kmemcheck_mark_unallocated_pages(struct page *p, unsigned int n)
> -{
> -	unsigned int i;
> -
> -	for (i = 0; i < n; ++i)
> -		kmemcheck_mark_unallocated(page_address(&p[i]), PAGE_SIZE);
> -}
> -
> -void kmemcheck_mark_uninitialized_pages(struct page *p, unsigned int n)
> -{
> -	unsigned int i;
> -
> -	for (i = 0; i < n; ++i)
> -		kmemcheck_mark_uninitialized(page_address(&p[i]), PAGE_SIZE);
> -}
> -
> -void kmemcheck_mark_initialized_pages(struct page *p, unsigned int n)
> -{
> -	unsigned int i;
> -
> -	for (i = 0; i < n; ++i)
> -		kmemcheck_mark_initialized(page_address(&p[i]), PAGE_SIZE);
> -}
> -
> -enum kmemcheck_shadow kmemcheck_shadow_test(void *shadow, unsigned int size)
> -{
> -#ifdef CONFIG_KMEMCHECK_PARTIAL_OK
> -	uint8_t *x;
> -	unsigned int i;
> -
> -	x = shadow;
> -
> -	/*
> -	 * Make sure _some_ bytes are initialized. Gcc frequently generates
> -	 * code to access neighboring bytes.
> -	 */
> -	for (i = 0; i < size; ++i) {
> -		if (x[i] == KMEMCHECK_SHADOW_INITIALIZED)
> -			return x[i];
> -	}
> -
> -	return x[0];
> -#else
> -	return kmemcheck_shadow_test_all(shadow, size);
> -#endif
> -}
> -
> -enum kmemcheck_shadow kmemcheck_shadow_test_all(void *shadow, unsigned int size)
> -{
> -	uint8_t *x;
> -	unsigned int i;
> -
> -	x = shadow;
> -
> -	/* All bytes must be initialized. */
> -	for (i = 0; i < size; ++i) {
> -		if (x[i] != KMEMCHECK_SHADOW_INITIALIZED)
> -			return x[i];
> -	}
> -
> -	return x[0];
> -}
> -
> -void kmemcheck_shadow_set(void *shadow, unsigned int size)
> -{
> -	uint8_t *x;
> -	unsigned int i;
> -
> -	x = shadow;
> -	for (i = 0; i < size; ++i)
> -		x[i] = KMEMCHECK_SHADOW_INITIALIZED;
> -}
> diff --git a/arch/x86/mm/kmemcheck/shadow.h b/arch/x86/mm/kmemcheck/shadow.h
> deleted file mode 100644
> index ff0b2f7..0000000
> --- a/arch/x86/mm/kmemcheck/shadow.h
> +++ /dev/null
> @@ -1,18 +0,0 @@
> -#ifndef ARCH__X86__MM__KMEMCHECK__SHADOW_H
> -#define ARCH__X86__MM__KMEMCHECK__SHADOW_H
> -
> -enum kmemcheck_shadow {
> -	KMEMCHECK_SHADOW_UNALLOCATED,
> -	KMEMCHECK_SHADOW_UNINITIALIZED,
> -	KMEMCHECK_SHADOW_INITIALIZED,
> -	KMEMCHECK_SHADOW_FREED,
> -};
> -
> -void *kmemcheck_shadow_lookup(unsigned long address);
> -
> -enum kmemcheck_shadow kmemcheck_shadow_test(void *shadow, unsigned int size);
> -enum kmemcheck_shadow kmemcheck_shadow_test_all(void *shadow,
> -						unsigned int size);
> -void kmemcheck_shadow_set(void *shadow, unsigned int size);
> -
> -#endif
> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
> index 89af288..e3165c2 100644
> --- a/arch/x86/mm/pageattr.c
> +++ b/arch/x86/mm/pageattr.c
> @@ -684,7 +684,7 @@ static int split_large_page(struct cpa_data *cpa, pte_t *kpte,
>  
>  	if (!debug_pagealloc)
>  		spin_unlock(&cpa_lock);
> -	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
> +	base = alloc_pages(GFP_KERNEL, 0);
>  	if (!debug_pagealloc)
>  		spin_lock(&cpa_lock);
>  	if (!base)
> @@ -857,7 +857,7 @@ static void unmap_pgd_range(pgd_t *root, unsigned long addr, unsigned long end)
>  
>  static int alloc_pte_page(pmd_t *pmd)
>  {
> -	pte_t *pte = (pte_t *)get_zeroed_page(GFP_KERNEL | __GFP_NOTRACK);
> +	pte_t *pte = (pte_t *)get_zeroed_page(GFP_KERNEL);
>  	if (!pte)
>  		return -1;
>  
> @@ -867,7 +867,7 @@ static int alloc_pte_page(pmd_t *pmd)
>  
>  static int alloc_pmd_page(pud_t *pud)
>  {
> -	pmd_t *pmd = (pmd_t *)get_zeroed_page(GFP_KERNEL | __GFP_NOTRACK);
> +	pmd_t *pmd = (pmd_t *)get_zeroed_page(GFP_KERNEL);
>  	if (!pmd)
>  		return -1;
>  
> @@ -1066,7 +1066,7 @@ static int populate_pgd(struct cpa_data *cpa, unsigned long addr)
>  	 * Allocate a PUD page and hand it down for mapping.
>  	 */
>  	if (pgd_none(*pgd_entry)) {
> -		pud = (pud_t *)get_zeroed_page(GFP_KERNEL | __GFP_NOTRACK);
> +		pud = (pud_t *)get_zeroed_page(GFP_KERNEL);
>  		if (!pud)
>  			return -1;
>  
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 0b97d2c..fbe5c6c 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -6,7 +6,7 @@
>  #include <asm/fixmap.h>
>  #include <asm/mtrr.h>
>  
> -#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
> +#define PGALLOC_GFP GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO
>  
>  #ifdef CONFIG_HIGHPTE
>  #define PGALLOC_USER_GFP __GFP_HIGHMEM
> diff --git a/crypto/xor.c b/crypto/xor.c
> index 35d6b3a..bdbf21c 100644
> --- a/crypto/xor.c
> +++ b/crypto/xor.c
> @@ -109,12 +109,7 @@ calibrate_xor_blocks(void)
>  	void *b1, *b2;
>  	struct xor_block_template *f, *fastest;
>  
> -	/*
> -	 * Note: Since the memory is not actually used for _anything_ but to
> -	 * test the XOR speed, we don't really want kmemcheck to warn about
> -	 * reading uninitialized bytes here.
> -	 */
> -	b1 = (void *) __get_free_pages(GFP_KERNEL | __GFP_NOTRACK, 2);
> +	b1 = (void *) __get_free_pages(GFP_KERNEL, 2);
>  	if (!b1) {
>  		printk(KERN_WARNING "xor: Yikes!  No memory available.\n");
>  		return -ENOMEM;
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index 9cd6968..a750398 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -255,7 +255,6 @@
>  #include <linux/cryptohash.h>
>  #include <linux/fips.h>
>  #include <linux/ptrace.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/workqueue.h>
>  #include <linux/irq.h>
>  #include <linux/syscalls.h>
> diff --git a/drivers/misc/c2port/core.c b/drivers/misc/c2port/core.c
> index 464419b..8b37f11 100644
> --- a/drivers/misc/c2port/core.c
> +++ b/drivers/misc/c2port/core.c
> @@ -15,7 +15,6 @@
>  #include <linux/errno.h>
>  #include <linux/err.h>
>  #include <linux/kernel.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/ctype.h>
>  #include <linux/delay.h>
>  #include <linux/idr.h>
> @@ -908,7 +907,6 @@ struct c2port_device *c2port_device_register(char *name,
>  		return ERR_PTR(-EINVAL);
>  
>  	c2dev = kmalloc(sizeof(struct c2port_device), GFP_KERNEL);
> -	kmemcheck_annotate_bitfield(c2dev, flags);
>  	if (unlikely(!c2dev))
>  		return ERR_PTR(-ENOMEM);
>  
> diff --git a/fs/dcache.c b/fs/dcache.c
> index c71e373..adb4c6e 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -2469,8 +2469,6 @@ static void swap_names(struct dentry *dentry, struct dentry *target)
>  			 */
>  			unsigned int i;
>  			BUILD_BUG_ON(!IS_ALIGNED(DNAME_INLINE_LEN, sizeof(long)));
> -			kmemcheck_mark_initialized(dentry->d_iname, DNAME_INLINE_LEN);
> -			kmemcheck_mark_initialized(target->d_iname, DNAME_INLINE_LEN);
>  			for (i = 0; i < DNAME_INLINE_LEN / sizeof(long); i++) {
>  				swap(((long *) &dentry->d_iname)[i],
>  				     ((long *) &target->d_iname)[i]);
> diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
> index 940d5ec..0d9e5b7 100644
> --- a/include/asm-generic/dma-mapping-common.h
> +++ b/include/asm-generic/dma-mapping-common.h
> @@ -1,7 +1,6 @@
>  #ifndef _ASM_GENERIC_DMA_MAPPING_H
>  #define _ASM_GENERIC_DMA_MAPPING_H
>  
> -#include <linux/kmemcheck.h>
>  #include <linux/bug.h>
>  #include <linux/scatterlist.h>
>  #include <linux/dma-debug.h>
> @@ -15,7 +14,6 @@ static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
>  	struct dma_map_ops *ops = get_dma_ops(dev);
>  	dma_addr_t addr;
>  
> -	kmemcheck_mark_initialized(ptr, size);
>  	BUG_ON(!valid_dma_direction(dir));
>  	addr = ops->map_page(dev, virt_to_page(ptr),
>  			     (unsigned long)ptr & ~PAGE_MASK, size,
> @@ -48,11 +46,8 @@ static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
>  				   struct dma_attrs *attrs)
>  {
>  	struct dma_map_ops *ops = get_dma_ops(dev);
> -	int i, ents;
> -	struct scatterlist *s;
> +	int ents;
>  
> -	for_each_sg(sg, s, nents, i)
> -		kmemcheck_mark_initialized(sg_virt(s), s->length);
>  	BUG_ON(!valid_dma_direction(dir));
>  	ents = ops->map_sg(dev, sg, nents, dir, attrs);
>  	BUG_ON(ents < 0);
> @@ -80,7 +75,6 @@ static inline dma_addr_t dma_map_page(struct device *dev, struct page *page,
>  	struct dma_map_ops *ops = get_dma_ops(dev);
>  	dma_addr_t addr;
>  
> -	kmemcheck_mark_initialized(page_address(page) + offset, size);
>  	BUG_ON(!valid_dma_direction(dir));
>  	addr = ops->map_page(dev, page, offset, size, dir, NULL);
>  	debug_dma_map_page(dev, page, offset, size, dir, addr, false);
> diff --git a/include/linux/c2port.h b/include/linux/c2port.h
> index 4efabcb..f273634 100644
> --- a/include/linux/c2port.h
> +++ b/include/linux/c2port.h
> @@ -9,8 +9,6 @@
>   * the Free Software Foundation
>   */
>  
> -#include <linux/kmemcheck.h>
> -
>  #define C2PORT_NAME_LEN			32
>  
>  struct device;
> @@ -22,10 +20,8 @@ struct device;
>  /* Main struct */
>  struct c2port_ops;
>  struct c2port_device {
> -	kmemcheck_bitfield_begin(flags);
>  	unsigned int access:1;
>  	unsigned int flash_access:1;
> -	kmemcheck_bitfield_end(flags);
>  
>  	int id;
>  	char name[C2PORT_NAME_LEN];
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 97a9373..3289a61 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -30,7 +30,6 @@ struct vm_area_struct;
>  #define ___GFP_HARDWALL		0x20000u
>  #define ___GFP_THISNODE		0x40000u
>  #define ___GFP_RECLAIMABLE	0x80000u
> -#define ___GFP_NOTRACK		0x200000u
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
>  #define ___GFP_WRITE		0x1000000u
> @@ -87,18 +86,11 @@ struct vm_area_struct;
>  #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
>  #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
>  #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
> -#define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
>  
>  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
>  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
>  #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
>  
> -/*
> - * This may seem redundant, but it's a way of annotating false positives vs.
> - * allocations that simply cannot be supported (e.g. page tables).
> - */
> -#define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
> -
>  #define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index 150dde0..1e08e71 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -530,6 +530,8 @@ static inline void tasklet_hi_schedule(struct tasklet_struct *t)
>  extern void __tasklet_hi_schedule_first(struct tasklet_struct *t);
>  
>  /*
> + * TODO: kmemcheck is gone, fix this.
> + *
>   * This version avoids touching any other tasklets. Needed for kmemcheck
>   * in order not to take any page faults while enqueueing this tasklet;
>   * consider VERY carefully whether you really need this or
> diff --git a/include/linux/kmemcheck.h b/include/linux/kmemcheck.h
> deleted file mode 100644
> index 39f8453..0000000
> --- a/include/linux/kmemcheck.h
> +++ /dev/null
> @@ -1,171 +0,0 @@
> -#ifndef LINUX_KMEMCHECK_H
> -#define LINUX_KMEMCHECK_H
> -
> -#include <linux/mm_types.h>
> -#include <linux/types.h>
> -
> -#ifdef CONFIG_KMEMCHECK
> -extern int kmemcheck_enabled;
> -
> -/* The slab-related functions. */
> -void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node);
> -void kmemcheck_free_shadow(struct page *page, int order);
> -void kmemcheck_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, void *object,
> -			  size_t size);
> -void kmemcheck_slab_free(struct kmem_cache *s, void *object, size_t size);
> -
> -void kmemcheck_pagealloc_alloc(struct page *p, unsigned int order,
> -			       gfp_t gfpflags);
> -
> -void kmemcheck_show_pages(struct page *p, unsigned int n);
> -void kmemcheck_hide_pages(struct page *p, unsigned int n);
> -
> -bool kmemcheck_page_is_tracked(struct page *p);
> -
> -void kmemcheck_mark_unallocated(void *address, unsigned int n);
> -void kmemcheck_mark_uninitialized(void *address, unsigned int n);
> -void kmemcheck_mark_initialized(void *address, unsigned int n);
> -void kmemcheck_mark_freed(void *address, unsigned int n);
> -
> -void kmemcheck_mark_unallocated_pages(struct page *p, unsigned int n);
> -void kmemcheck_mark_uninitialized_pages(struct page *p, unsigned int n);
> -void kmemcheck_mark_initialized_pages(struct page *p, unsigned int n);
> -
> -int kmemcheck_show_addr(unsigned long address);
> -int kmemcheck_hide_addr(unsigned long address);
> -
> -bool kmemcheck_is_obj_initialized(unsigned long addr, size_t size);
> -
> -/*
> - * Bitfield annotations
> - *
> - * How to use: If you have a struct using bitfields, for example
> - *
> - *     struct a {
> - *             int x:8, y:8;
> - *     };
> - *
> - * then this should be rewritten as
> - *
> - *     struct a {
> - *             kmemcheck_bitfield_begin(flags);
> - *             int x:8, y:8;
> - *             kmemcheck_bitfield_end(flags);
> - *     };
> - *
> - * Now the "flags_begin" and "flags_end" members may be used to refer to the
> - * beginning and end, respectively, of the bitfield (and things like
> - * &x.flags_begin is allowed). As soon as the struct is allocated, the bit-
> - * fields should be annotated:
> - *
> - *     struct a *a = kmalloc(sizeof(struct a), GFP_KERNEL);
> - *     kmemcheck_annotate_bitfield(a, flags);
> - */
> -#define kmemcheck_bitfield_begin(name)	\
> -	int name##_begin[0];
> -
> -#define kmemcheck_bitfield_end(name)	\
> -	int name##_end[0];
> -
> -#define kmemcheck_annotate_bitfield(ptr, name)				\
> -	do {								\
> -		int _n;							\
> -									\
> -		if (!ptr)						\
> -			break;						\
> -									\
> -		_n = (long) &((ptr)->name##_end)			\
> -			- (long) &((ptr)->name##_begin);		\
> -		BUILD_BUG_ON(_n < 0);					\
> -									\
> -		kmemcheck_mark_initialized(&((ptr)->name##_begin), _n);	\
> -	} while (0)
> -
> -#define kmemcheck_annotate_variable(var)				\
> -	do {								\
> -		kmemcheck_mark_initialized(&(var), sizeof(var));	\
> -	} while (0)							\
> -
> -#else
> -#define kmemcheck_enabled 0
> -
> -static inline void
> -kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
> -{
> -}
> -
> -static inline void
> -kmemcheck_free_shadow(struct page *page, int order)
> -{
> -}
> -
> -static inline void
> -kmemcheck_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, void *object,
> -		     size_t size)
> -{
> -}
> -
> -static inline void kmemcheck_slab_free(struct kmem_cache *s, void *object,
> -				       size_t size)
> -{
> -}
> -
> -static inline void kmemcheck_pagealloc_alloc(struct page *p,
> -	unsigned int order, gfp_t gfpflags)
> -{
> -}
> -
> -static inline bool kmemcheck_page_is_tracked(struct page *p)
> -{
> -	return false;
> -}
> -
> -static inline void kmemcheck_mark_unallocated(void *address, unsigned int n)
> -{
> -}
> -
> -static inline void kmemcheck_mark_uninitialized(void *address, unsigned int n)
> -{
> -}
> -
> -static inline void kmemcheck_mark_initialized(void *address, unsigned int n)
> -{
> -}
> -
> -static inline void kmemcheck_mark_freed(void *address, unsigned int n)
> -{
> -}
> -
> -static inline void kmemcheck_mark_unallocated_pages(struct page *p,
> -						    unsigned int n)
> -{
> -}
> -
> -static inline void kmemcheck_mark_uninitialized_pages(struct page *p,
> -						      unsigned int n)
> -{
> -}
> -
> -static inline void kmemcheck_mark_initialized_pages(struct page *p,
> -						    unsigned int n)
> -{
> -}
> -
> -static inline bool kmemcheck_is_obj_initialized(unsigned long addr, size_t size)
> -{
> -	return true;
> -}
> -
> -#define kmemcheck_bitfield_begin(name)
> -#define kmemcheck_bitfield_end(name)
> -#define kmemcheck_annotate_bitfield(ptr, name)	\
> -	do {					\
> -	} while (0)
> -
> -#define kmemcheck_annotate_variable(var)	\
> -	do {					\
> -	} while (0)
> -
> -#endif /* CONFIG_KMEMCHECK */
> -
> -#endif /* LINUX_KMEMCHECK_H */
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 590630e..839fd36 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -194,14 +194,6 @@ struct page {
>  					   not kmapped, ie. highmem) */
>  #endif /* WANT_PAGE_VIRTUAL */
>  
> -#ifdef CONFIG_KMEMCHECK
> -	/*
> -	 * kmemcheck wants to track the status of each byte in a page; this
> -	 * is a pointer to such a status block. NULL if not tracked.
> -	 */
> -	void *shadow;
> -#endif
> -
>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>  	int _last_cpupid;
>  #endif
> diff --git a/include/linux/net.h b/include/linux/net.h
> index e74114b..aeab094 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -22,7 +22,6 @@
>  #include <linux/random.h>
>  #include <linux/wait.h>
>  #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
> -#include <linux/kmemcheck.h>
>  #include <linux/rcupdate.h>
>  #include <linux/jump_label.h>
>  #include <uapi/linux/net.h>
> @@ -105,9 +104,7 @@ struct socket_wq {
>  struct socket {
>  	socket_state		state;
>  
> -	kmemcheck_bitfield_begin(type);
>  	short			type;
> -	kmemcheck_bitfield_end(type);
>  
>  	unsigned long		flags;
>  
> diff --git a/include/linux/ring_buffer.h b/include/linux/ring_buffer.h
> index e2c13cd..b92b3ee 100644
> --- a/include/linux/ring_buffer.h
> +++ b/include/linux/ring_buffer.h
> @@ -1,7 +1,6 @@
>  #ifndef _LINUX_RING_BUFFER_H
>  #define _LINUX_RING_BUFFER_H
>  
> -#include <linux/kmemcheck.h>
>  #include <linux/mm.h>
>  #include <linux/seq_file.h>
>  #include <linux/poll.h>
> @@ -13,9 +12,7 @@ struct ring_buffer_iter;
>   * Don't refer to this struct directly, use functions below.
>   */
>  struct ring_buffer_event {
> -	kmemcheck_bitfield_begin(bitfield);
>  	u32		type_len:5, time_delta:27;
> -	kmemcheck_bitfield_end(bitfield);
>  
>  	u32		array[];
>  };
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index bba1330..a174f1d 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -15,7 +15,6 @@
>  #define _LINUX_SKBUFF_H
>  
>  #include <linux/kernel.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/compiler.h>
>  #include <linux/time.h>
>  #include <linux/bug.h>
> @@ -553,7 +552,6 @@ struct sk_buff {
>  	/* Following fields are _not_ copied in __copy_skb_header()
>  	 * Note that queue_mapping is here mostly to fill a hole.
>  	 */
> -	kmemcheck_bitfield_begin(flags1);
>  	__u16			queue_mapping;
>  	__u8			cloned:1,
>  				nohdr:1,
> @@ -562,7 +560,6 @@ struct sk_buff {
>  				head_frag:1,
>  				xmit_more:1;
>  	/* one bit hole */
> -	kmemcheck_bitfield_end(flags1);
>  
>  	/* fields enclosed in headers_start/headers_end are copied
>  	 * using a single memcpy() in __copy_skb_header()
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 76f1fee..7dc2d9c 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -75,12 +75,6 @@
>  
>  #define SLAB_NOLEAKTRACE	0x00800000UL	/* Avoid kmemleak tracing */
>  
> -/* Don't track use of uninitialized memory */
> -#ifdef CONFIG_KMEMCHECK
> -# define SLAB_NOTRACK		0x01000000UL
> -#else
> -# define SLAB_NOTRACK		0x00000000UL
> -#endif
>  #ifdef CONFIG_FAILSLAB
>  # define SLAB_FAILSLAB		0x02000000UL	/* Fault injection mark */
>  #else
> diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
> index ff307b5..1ce28a5 100644
> --- a/include/linux/thread_info.h
> +++ b/include/linux/thread_info.h
> @@ -56,9 +56,9 @@ extern long do_no_restart_syscall(struct restart_block *parm);
>  #ifdef __KERNEL__
>  
>  #ifdef CONFIG_DEBUG_STACK_USAGE
> -# define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
> +# define THREADINFO_GFP		(GFP_KERNEL | __GFP_ZERO)
>  #else
> -# define THREADINFO_GFP		(GFP_KERNEL | __GFP_NOTRACK)
> +# define THREADINFO_GFP		(GFP_KERNEL)
>  #endif
>  
>  /*
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index eb16c7b..3b9dee7 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -17,7 +17,6 @@
>  #define _INET_SOCK_H
>  
>  #include <linux/bitops.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/string.h>
>  #include <linux/types.h>
>  #include <linux/jhash.h>
> @@ -78,7 +77,6 @@ struct inet_request_sock {
>  #define ir_v6_loc_addr		req.__req_common.skc_v6_rcv_saddr
>  #define ir_iif			req.__req_common.skc_bound_dev_if
>  
> -	kmemcheck_bitfield_begin(flags);
>  	u16			snd_wscale : 4,
>  				rcv_wscale : 4,
>  				tstamp_ok  : 1,
> @@ -87,7 +85,6 @@ struct inet_request_sock {
>  				ecn_ok	   : 1,
>  				acked	   : 1,
>  				no_srccheck: 1;
> -	kmemcheck_bitfield_end(flags);
>  	union {
>  		struct ip_options_rcu	*opt;
>  		struct sk_buff		*pktopts;
> @@ -244,10 +241,8 @@ static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops
>  	struct request_sock *req = reqsk_alloc(ops);
>  	struct inet_request_sock *ireq = inet_rsk(req);
>  
> -	if (req != NULL) {
> -		kmemcheck_annotate_bitfield(ireq, flags);
> +	if (req != NULL)
>  		ireq->opt = NULL;
> -	}
>  
>  	return req;
>  }
> diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
> index 6c56603..449b9c8 100644
> --- a/include/net/inet_timewait_sock.h
> +++ b/include/net/inet_timewait_sock.h
> @@ -16,7 +16,6 @@
>  #define _INET_TIMEWAIT_SOCK_
>  
>  
> -#include <linux/kmemcheck.h>
>  #include <linux/list.h>
>  #include <linux/timer.h>
>  #include <linux/types.h>
> @@ -130,14 +129,12 @@ struct inet_timewait_sock {
>  	/* Socket demultiplex comparisons on incoming packets. */
>  	/* these three are in inet_sock */
>  	__be16			tw_sport;
> -	kmemcheck_bitfield_begin(flags);
>  	/* And these are ours. */
>  	unsigned int		tw_pad0		: 1,	/* 1 bit hole */
>  				tw_transparent  : 1,
>  				tw_flowlabel	: 20,
>  				tw_pad		: 2,	/* 2 bits hole */
>  				tw_tos		: 8;
> -	kmemcheck_bitfield_end(flags);
>  	u32			tw_ttd;
>  	struct inet_bind_bucket	*tw_tb;
>  	struct hlist_node	tw_death_node;
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 250822c..eeaad3a 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -379,14 +379,12 @@ struct sock {
>  	atomic_t		sk_omem_alloc;
>  	int			sk_sndbuf;
>  	struct sk_buff_head	sk_write_queue;
> -	kmemcheck_bitfield_begin(flags);
>  	unsigned int		sk_shutdown  : 2,
>  				sk_no_check_tx : 1,
>  				sk_no_check_rx : 1,
>  				sk_userlocks : 4,
>  				sk_protocol  : 8,
>  				sk_type      : 16;
> -	kmemcheck_bitfield_end(flags);
>  	int			sk_wmem_queued;
>  	gfp_t			sk_allocation;
>  	u32			sk_pacing_rate; /* bytes per second */
> diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
> index d6fd8e5..42bde43 100644
> --- a/include/trace/events/gfpflags.h
> +++ b/include/trace/events/gfpflags.h
> @@ -35,7 +35,6 @@
>  	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
>  	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
>  	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"},		\
> -	{(unsigned long)__GFP_NOTRACK,		"GFP_NOTRACK"},		\
>  	{(unsigned long)__GFP_NO_KSWAPD,	"GFP_NO_KSWAPD"},	\
>  	{(unsigned long)__GFP_OTHER_NODE,	"GFP_OTHER_NODE"}	\
>  	) : "GFP_NOWAIT"
> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index eb41008..2ba082b 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -377,8 +377,7 @@ static int __init do_mount_root(char *name, char *fs, int flags, void *data)
>  
>  void __init mount_block_root(char *name, int flags)
>  {
> -	struct page *page = alloc_page(GFP_KERNEL |
> -					__GFP_NOTRACK_FALSE_POSITIVE);
> +	struct page *page = alloc_page(GFP_KERNEL);
>  	char *fs_names = page_address(page);
>  	char *p;
>  #ifdef CONFIG_BLOCK
> diff --git a/init/main.c b/init/main.c
> index 739a677..ba6194b 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -65,7 +65,6 @@
>  #include <linux/kgdb.h>
>  #include <linux/ftrace.h>
>  #include <linux/async.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/sfi.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/slab.h>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index ab1a008..a2797b8 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -262,7 +262,7 @@ void __init fork_init(unsigned long mempages)
>  	/* create a slab on which task_structs can be allocated */
>  	task_struct_cachep =
>  		kmem_cache_create("task_struct", sizeof(struct task_struct),
> -			ARCH_MIN_TASKALIGN, SLAB_PANIC | SLAB_NOTRACK, NULL);
> +			ARCH_MIN_TASKALIGN, SLAB_PANIC, NULL);
>  #endif
>  
>  	/* do the arch specific task caches init */
> @@ -1773,17 +1773,17 @@ void __init proc_caches_init(void)
>  {
>  	sighand_cachep = kmem_cache_create("sighand_cache",
>  			sizeof(struct sighand_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU|
> -			SLAB_NOTRACK, sighand_ctor);
> +			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU,
> +			sighand_ctor);
>  	signal_cachep = kmem_cache_create("signal_cache",
>  			sizeof(struct signal_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>  	files_cachep = kmem_cache_create("files_cache",
>  			sizeof(struct files_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>  	fs_cachep = kmem_cache_create("fs_cache",
>  			sizeof(struct fs_struct), 0,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>  	/*
>  	 * FIXME! The "sizeof(struct mm_struct)" currently includes the
>  	 * whole struct cpumask for the OFFSTACK case. We could change
> @@ -1793,7 +1793,7 @@ void __init proc_caches_init(void)
>  	 */
>  	mm_cachep = kmem_cache_create("mm_struct",
>  			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
> -			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
> +			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
>  	vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC);
>  	mmap_init();
>  	nsproxy_cache_init();
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 88d0d44..a2870fb 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -44,7 +44,6 @@
>  #include <linux/stringify.h>
>  #include <linux/bitops.h>
>  #include <linux/gfp.h>
> -#include <linux/kmemcheck.h>
>  
>  #include <asm/sections.h>
>  
> @@ -2956,8 +2955,6 @@ void lockdep_init_map(struct lockdep_map *lock, const char *name,
>  {
>  	int i;
>  
> -	kmemcheck_mark_initialized(lock, sizeof(*lock));
> -
>  	for (i = 0; i < NR_LOCKDEP_CACHING_CLASSES; i++)
>  		lock->class_cache[i] = NULL;
>  
> diff --git a/kernel/signal.c b/kernel/signal.c
> index a390499..778c636 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1067,8 +1067,7 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  	else
>  		override_rlimit = 0;
>  
> -	q = __sigqueue_alloc(sig, t, GFP_ATOMIC | __GFP_NOTRACK_FALSE_POSITIVE,
> -		override_rlimit);
> +	q = __sigqueue_alloc(sig, t, GFP_ATOMIC, override_rlimit);
>  	if (q) {
>  		list_add_tail(&q->list, &pending->list);
>  		switch ((unsigned long) info) {
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index c155263..c62ee41 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -29,7 +29,6 @@
>  #include <linux/proc_fs.h>
>  #include <linux/security.h>
>  #include <linux/ctype.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/kmemleak.h>
>  #include <linux/fs.h>
>  #include <linux/init.h>
> @@ -1115,15 +1114,6 @@ static struct ctl_table kern_table[] = {
>  		.extra2		= &one_hundred,
>  	},
>  #endif
> -#ifdef CONFIG_KMEMCHECK
> -	{
> -		.procname	= "kmemcheck",
> -		.data		= &kmemcheck_enabled,
> -		.maxlen		= sizeof(int),
> -		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> -	},
> -#endif
>  	{
>  		.procname	= "panic_on_warn",
>  		.data		= &panic_on_warn,
> diff --git a/kernel/trace/ring_buffer.c b/kernel/trace/ring_buffer.c
> index 5040d44..d670d73 100644
> --- a/kernel/trace/ring_buffer.c
> +++ b/kernel/trace/ring_buffer.c
> @@ -12,7 +12,6 @@
>  #include <linux/uaccess.h>
>  #include <linux/hardirq.h>
>  #include <linux/kthread.h>	/* for self test */
> -#include <linux/kmemcheck.h>
>  #include <linux/module.h>
>  #include <linux/percpu.h>
>  #include <linux/mutex.h>
> @@ -2260,7 +2259,6 @@ rb_reset_tail(struct ring_buffer_per_cpu *cpu_buffer,
>  	}
>  
>  	event = __rb_page_index(tail_page, tail);
> -	kmemcheck_annotate_bitfield(event, bitfield);
>  
>  	/* account for padding bytes */
>  	local_add(BUF_PAGE_SIZE - tail, &cpu_buffer->entries_bytes);
> @@ -2453,7 +2451,6 @@ __rb_reserve_next(struct ring_buffer_per_cpu *cpu_buffer,
>  	/* We reserved something on the buffer */
>  
>  	event = __rb_page_index(tail_page, tail);
> -	kmemcheck_annotate_bitfield(event, bitfield);
>  	rb_update_event(cpu_buffer, event, length, add_timestamp, delta);
>  
>  	local_inc(&tail_page->entries);
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index cc805d4..6861cc2 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -445,7 +445,7 @@ config DEBUG_OBJECTS_ENABLE_DEFAULT
>  
>  config DEBUG_SLAB
>  	bool "Debug slab memory allocations"
> -	depends on DEBUG_KERNEL && SLAB && !KMEMCHECK
> +	depends on DEBUG_KERNEL && SLAB
>  	help
>  	  Say Y here to have the kernel do limited verification on memory
>  	  allocation as well as poisoning memory on free to catch use of freed
> @@ -457,7 +457,7 @@ config DEBUG_SLAB_LEAK
>  
>  config SLUB_DEBUG_ON
>  	bool "SLUB debugging on by default"
> -	depends on SLUB && SLUB_DEBUG && !KMEMCHECK
> +	depends on SLUB && SLUB_DEBUG
>  	default n
>  	help
>  	  Boot with debugging on by default. SLUB boots by default with
> @@ -660,8 +660,6 @@ config DEBUG_STACKOVERFLOW
>  
>  	  If in doubt, say "N".
>  
> -source "lib/Kconfig.kmemcheck"
> -
>  source "lib/Kconfig.kasan"
>  
>  endmenu # "Memory Debugging"
> diff --git a/lib/Kconfig.kmemcheck b/lib/Kconfig.kmemcheck
> deleted file mode 100644
> index 846e039..0000000
> --- a/lib/Kconfig.kmemcheck
> +++ /dev/null
> @@ -1,94 +0,0 @@
> -config HAVE_ARCH_KMEMCHECK
> -	bool
> -
> -if HAVE_ARCH_KMEMCHECK
> -
> -menuconfig KMEMCHECK
> -	bool "kmemcheck: trap use of uninitialized memory"
> -	depends on DEBUG_KERNEL
> -	depends on !X86_USE_3DNOW
> -	depends on SLUB || SLAB
> -	depends on !CC_OPTIMIZE_FOR_SIZE
> -	depends on !FUNCTION_TRACER
> -	select FRAME_POINTER
> -	select STACKTRACE
> -	default n
> -	help
> -	  This option enables tracing of dynamically allocated kernel memory
> -	  to see if memory is used before it has been given an initial value.
> -	  Be aware that this requires half of your memory for bookkeeping and
> -	  will insert extra code at *every* read and write to tracked memory
> -	  thus slow down the kernel code (but user code is unaffected).
> -
> -	  The kernel may be started with kmemcheck=0 or kmemcheck=1 to disable
> -	  or enable kmemcheck at boot-time. If the kernel is started with
> -	  kmemcheck=0, the large memory and CPU overhead is not incurred.
> -
> -choice
> -	prompt "kmemcheck: default mode at boot"
> -	depends on KMEMCHECK
> -	default KMEMCHECK_ONESHOT_BY_DEFAULT
> -	help
> -	  This option controls the default behaviour of kmemcheck when the
> -	  kernel boots and no kmemcheck= parameter is given.
> -
> -config KMEMCHECK_DISABLED_BY_DEFAULT
> -	bool "disabled"
> -	depends on KMEMCHECK
> -
> -config KMEMCHECK_ENABLED_BY_DEFAULT
> -	bool "enabled"
> -	depends on KMEMCHECK
> -
> -config KMEMCHECK_ONESHOT_BY_DEFAULT
> -	bool "one-shot"
> -	depends on KMEMCHECK
> -	help
> -	  In one-shot mode, only the first error detected is reported before
> -	  kmemcheck is disabled.
> -
> -endchoice
> -
> -config KMEMCHECK_QUEUE_SIZE
> -	int "kmemcheck: error queue size"
> -	depends on KMEMCHECK
> -	default 64
> -	help
> -	  Select the maximum number of errors to store in the queue. Since
> -	  errors can occur virtually anywhere and in any context, we need a
> -	  temporary storage area which is guarantueed not to generate any
> -	  other faults. The queue will be emptied as soon as a tasklet may
> -	  be scheduled. If the queue is full, new error reports will be
> -	  lost.
> -
> -config KMEMCHECK_SHADOW_COPY_SHIFT
> -	int "kmemcheck: shadow copy size (5 => 32 bytes, 6 => 64 bytes)"
> -	depends on KMEMCHECK
> -	range 2 8
> -	default 5
> -	help
> -	  Select the number of shadow bytes to save along with each entry of
> -	  the queue. These bytes indicate what parts of an allocation are
> -	  initialized, uninitialized, etc. and will be displayed when an
> -	  error is detected to help the debugging of a particular problem.
> -
> -config KMEMCHECK_PARTIAL_OK
> -	bool "kmemcheck: allow partially uninitialized memory"
> -	depends on KMEMCHECK
> -	default y
> -	help
> -	  This option works around certain GCC optimizations that produce
> -	  32-bit reads from 16-bit variables where the upper 16 bits are
> -	  thrown away afterwards. This may of course also hide some real
> -	  bugs.
> -
> -config KMEMCHECK_BITOPS_OK
> -	bool "kmemcheck: allow bit-field manipulation"
> -	depends on KMEMCHECK
> -	default n
> -	help
> -	  This option silences warnings that would be generated for bit-field
> -	  accesses where not all the bits are initialized at the same time.
> -	  This may also hide some real bugs.
> -
> -endif
> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index 957d3da..513ff4f 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -11,7 +11,6 @@ config DEBUG_PAGEALLOC
>  	bool "Debug page memory allocations"
>  	depends on DEBUG_KERNEL
>  	depends on !HIBERNATION || ARCH_SUPPORTS_DEBUG_PAGEALLOC && !PPC && !SPARC
> -	depends on !KMEMCHECK
>  	select PAGE_EXTENSION
>  	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
>  	---help---
> diff --git a/mm/Makefile b/mm/Makefile
> index 51052ba..fa388b1 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -51,7 +51,6 @@ obj-$(CONFIG_KSM) += ksm.o
>  obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
>  obj-$(CONFIG_SLAB) += slab.o
>  obj-$(CONFIG_SLUB) += slub.o
> -obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
>  obj-$(CONFIG_KASAN)	+= kasan/
>  obj-$(CONFIG_FAILSLAB) += failslab.o
>  obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
> diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
> deleted file mode 100644
> index cab58bb..0000000
> --- a/mm/kmemcheck.c
> +++ /dev/null
> @@ -1,123 +0,0 @@
> -#include <linux/gfp.h>
> -#include <linux/mm_types.h>
> -#include <linux/mm.h>
> -#include <linux/slab.h>
> -#include "slab.h"
> -#include <linux/kmemcheck.h>
> -
> -void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
> -{
> -	struct page *shadow;
> -	int pages;
> -	int i;
> -
> -	pages = 1 << order;
> -
> -	/*
> -	 * With kmemcheck enabled, we need to allocate a memory area for the
> -	 * shadow bits as well.
> -	 */
> -	shadow = alloc_pages_node(node, flags | __GFP_NOTRACK, order);
> -	if (!shadow) {
> -		if (printk_ratelimit())
> -			printk(KERN_ERR "kmemcheck: failed to allocate "
> -				"shadow bitmap\n");
> -		return;
> -	}
> -
> -	for(i = 0; i < pages; ++i)
> -		page[i].shadow = page_address(&shadow[i]);
> -
> -	/*
> -	 * Mark it as non-present for the MMU so that our accesses to
> -	 * this memory will trigger a page fault and let us analyze
> -	 * the memory accesses.
> -	 */
> -	kmemcheck_hide_pages(page, pages);
> -}
> -
> -void kmemcheck_free_shadow(struct page *page, int order)
> -{
> -	struct page *shadow;
> -	int pages;
> -	int i;
> -
> -	if (!kmemcheck_page_is_tracked(page))
> -		return;
> -
> -	pages = 1 << order;
> -
> -	kmemcheck_show_pages(page, pages);
> -
> -	shadow = virt_to_page(page[0].shadow);
> -
> -	for(i = 0; i < pages; ++i)
> -		page[i].shadow = NULL;
> -
> -	__free_pages(shadow, order);
> -}
> -
> -void kmemcheck_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, void *object,
> -			  size_t size)
> -{
> -	/*
> -	 * Has already been memset(), which initializes the shadow for us
> -	 * as well.
> -	 */
> -	if (gfpflags & __GFP_ZERO)
> -		return;
> -
> -	/* No need to initialize the shadow of a non-tracked slab. */
> -	if (s->flags & SLAB_NOTRACK)
> -		return;
> -
> -	if (!kmemcheck_enabled || gfpflags & __GFP_NOTRACK) {
> -		/*
> -		 * Allow notracked objects to be allocated from
> -		 * tracked caches. Note however that these objects
> -		 * will still get page faults on access, they just
> -		 * won't ever be flagged as uninitialized. If page
> -		 * faults are not acceptable, the slab cache itself
> -		 * should be marked NOTRACK.
> -		 */
> -		kmemcheck_mark_initialized(object, size);
> -	} else if (!s->ctor) {
> -		/*
> -		 * New objects should be marked uninitialized before
> -		 * they're returned to the called.
> -		 */
> -		kmemcheck_mark_uninitialized(object, size);
> -	}
> -}
> -
> -void kmemcheck_slab_free(struct kmem_cache *s, void *object, size_t size)
> -{
> -	/* TODO: RCU freeing is unsupported for now; hide false positives. */
> -	if (!s->ctor && !(s->flags & SLAB_DESTROY_BY_RCU))
> -		kmemcheck_mark_freed(object, size);
> -}
> -
> -void kmemcheck_pagealloc_alloc(struct page *page, unsigned int order,
> -			       gfp_t gfpflags)
> -{
> -	int pages;
> -
> -	if (gfpflags & (__GFP_HIGHMEM | __GFP_NOTRACK))
> -		return;
> -
> -	pages = 1 << order;
> -
> -	/*
> -	 * NOTE: We choose to track GFP_ZERO pages too; in fact, they
> -	 * can become uninitialized by copying uninitialized memory
> -	 * into them.
> -	 */
> -
> -	/* XXX: Can use zone->node for node? */
> -	kmemcheck_alloc_shadow(page, order, gfpflags, -1);
> -
> -	if (gfpflags & __GFP_ZERO)
> -		kmemcheck_mark_initialized_pages(page, pages);
> -	else
> -		kmemcheck_mark_uninitialized_pages(page, pages);
> -}
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 5405aff..09d9ecd 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -99,7 +99,6 @@
>  #include <linux/atomic.h>
>  
>  #include <linux/kasan.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/kmemleak.h>
>  #include <linux/memory_hotplug.h>
>  
> @@ -1111,9 +1110,6 @@ static bool update_checksum(struct kmemleak_object *object)
>  {
>  	u32 old_csum = object->checksum;
>  
> -	if (!kmemcheck_is_obj_initialized(object->pointer, object->size))
> -		return false;
> -
>  	kasan_disable_current();
>  	object->checksum = crc32(0, (void *)object->pointer, object->size);
>  	kasan_enable_current();
> @@ -1163,11 +1159,6 @@ static void scan_block(void *_start, void *_end,
>  		if (scan_should_stop())
>  			break;
>  
> -		/* don't scan uninitialized memory */
> -		if (!kmemcheck_is_obj_initialized((unsigned long)ptr,
> -						  BYTES_PER_POINTER))
> -			continue;
> -
>  		kasan_disable_current();
>  		pointer = *ptr;
>  		kasan_enable_current();
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1b84950..5f0b012 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -24,7 +24,6 @@
>  #include <linux/memblock.h>
>  #include <linux/compiler.h>
>  #include <linux/kernel.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/kasan.h>
>  #include <linux/module.h>
>  #include <linux/suspend.h>
> @@ -787,7 +786,6 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>  	VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
>  
>  	trace_mm_page_free(page, order);
> -	kmemcheck_free_shadow(page, order);
>  	kasan_free_pages(page, order);
>  
>  	if (PageAnon(page))
> @@ -1607,15 +1605,6 @@ void split_page(struct page *page, unsigned int order)
>  	VM_BUG_ON_PAGE(PageCompound(page), page);
>  	VM_BUG_ON_PAGE(!page_count(page), page);
>  
> -#ifdef CONFIG_KMEMCHECK
> -	/*
> -	 * Split shadow pages too, because free(page[0]) would
> -	 * otherwise free the whole shadow.
> -	 */
> -	if (kmemcheck_page_is_tracked(page))
> -		split_page(virt_to_page(page[0].shadow), order);
> -#endif
> -
>  	set_page_owner(page, 0, 0);
>  	for (i = 1; i < (1 << order); i++) {
>  		set_page_refcounted(page + i);
> @@ -2899,9 +2888,6 @@ retry_cpuset:
>  		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
>  	}
>  
> -	if (kmemcheck_enabled && page)
> -		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
> -
>  	trace_mm_page_alloc(page, order, alloc_mask, ac.migratetype);
>  
>  out:
> diff --git a/mm/slab.c b/mm/slab.c
> index 7eb38dd..763a615 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -113,7 +113,6 @@
>  #include	<linux/rtmutex.h>
>  #include	<linux/reciprocal_div.h>
>  #include	<linux/debugobjects.h>
> -#include	<linux/kmemcheck.h>
>  #include	<linux/memory.h>
>  #include	<linux/prefetch.h>
>  
> @@ -1594,7 +1593,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>  	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
>  		return NULL;
>  
> -	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
> +	page = alloc_pages_exact_node(nodeid, flags, cachep->gfporder);
>  	if (!page) {
>  		memcg_uncharge_slab(cachep, cachep->gfporder);
>  		slab_out_of_memory(cachep, flags, nodeid);
> @@ -1616,15 +1615,6 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>  	if (page->pfmemalloc)
>  		SetPageSlabPfmemalloc(page);
>  
> -	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
> -		kmemcheck_alloc_shadow(page, cachep->gfporder, flags, nodeid);
> -
> -		if (cachep->ctor)
> -			kmemcheck_mark_uninitialized_pages(page, nr_pages);
> -		else
> -			kmemcheck_mark_unallocated_pages(page, nr_pages);
> -	}
> -
>  	return page;
>  }
>  
> @@ -1635,8 +1625,6 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
>  {
>  	const unsigned long nr_freed = (1 << cachep->gfporder);
>  
> -	kmemcheck_free_shadow(page, cachep->gfporder);
> -
>  	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
>  		sub_zone_page_state(page_zone(page),
>  				NR_SLAB_RECLAIMABLE, nr_freed);
> @@ -3190,11 +3178,8 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>  	kmemleak_alloc_recursive(ptr, cachep->object_size, 1, cachep->flags,
>  				 flags);
>  
> -	if (likely(ptr)) {
> -		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
> -		if (unlikely(flags & __GFP_ZERO))
> -			memset(ptr, 0, cachep->object_size);
> -	}
> +	if (unlikely(ptr && (flags & __GFP_ZERO)))
> +		memset(ptr, 0, cachep->object_size);
>  
>  	memcg_kmem_put_cache(cachep);
>  	return ptr;
> @@ -3256,11 +3241,8 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
>  				 flags);
>  	prefetchw(objp);
>  
> -	if (likely(objp)) {
> -		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
> -		if (unlikely(flags & __GFP_ZERO))
> -			memset(objp, 0, cachep->object_size);
> -	}
> +	if (unlikely(objp && (flags & __GFP_ZERO)))
> +		memset(objp, 0, cachep->object_size);
>  
>  	memcg_kmem_put_cache(cachep);
>  	return objp;
> @@ -3374,8 +3356,6 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>  	kmemleak_free_recursive(objp, cachep->flags);
>  	objp = cache_free_debugcheck(cachep, objp, caller);
>  
> -	kmemcheck_slab_free(cachep, objp, cachep->object_size);
> -
>  	/*
>  	 * Skip calling cache_free_alien() when the platform is not numa.
>  	 * This will avoid cache misses that happen while accessing slabp (which
> diff --git a/mm/slab.h b/mm/slab.h
> index 4c3ac12..c61db47 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -127,10 +127,10 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>  
>  #if defined(CONFIG_SLAB)
>  #define SLAB_CACHE_FLAGS (SLAB_MEM_SPREAD | SLAB_NOLEAKTRACE | \
> -			  SLAB_RECLAIM_ACCOUNT | SLAB_TEMPORARY | SLAB_NOTRACK)
> +			  SLAB_RECLAIM_ACCOUNT | SLAB_TEMPORARY)
>  #elif defined(CONFIG_SLUB)
>  #define SLAB_CACHE_FLAGS (SLAB_NOLEAKTRACE | SLAB_RECLAIM_ACCOUNT | \
> -			  SLAB_TEMPORARY | SLAB_NOTRACK)
> +			  SLAB_TEMPORARY)
>  #else
>  #define SLAB_CACHE_FLAGS (0)
>  #endif
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 999bb34..75f0a5f 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -38,7 +38,7 @@ struct kmem_cache *kmem_cache;
>  		SLAB_FAILSLAB)
>  
>  #define SLAB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
> -		SLAB_CACHE_DMA | SLAB_NOTRACK)
> +		SLAB_CACHE_DMA)
>  
>  /*
>   * Merge control. If this is set then no merging of slab caches will occur.
> diff --git a/mm/slub.c b/mm/slub.c
> index 2584d4f..ed4aeb1 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -21,7 +21,6 @@
>  #include <linux/notifier.h>
>  #include <linux/seq_file.h>
>  #include <linux/kasan.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/cpu.h>
>  #include <linux/cpuset.h>
>  #include <linux/mempolicy.h>
> @@ -1275,7 +1274,6 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
>  					gfp_t flags, void *object)
>  {
>  	flags &= gfp_allowed_mask;
> -	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
>  	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
>  	memcg_kmem_put_cache(s);
>  	kasan_slab_alloc(s, object);
> @@ -1290,12 +1288,11 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
>  	 * So in order to make the debug calls that expect irqs to be
>  	 * disabled we need to disable interrupts temporarily.
>  	 */
> -#if defined(CONFIG_KMEMCHECK) || defined(CONFIG_LOCKDEP)
> +#if defined(CONFIG_LOCKDEP)
>  	{
>  		unsigned long flags;
>  
>  		local_irq_save(flags);
> -		kmemcheck_slab_free(s, x, s->object_size);
>  		debug_check_no_locks_freed(x, s->object_size);
>  		local_irq_restore(flags);
>  	}
> @@ -1315,8 +1312,6 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
>  	struct page *page;
>  	int order = oo_order(oo);
>  
> -	flags |= __GFP_NOTRACK;
> -
>  	if (memcg_charge_slab(s, flags, order))
>  		return NULL;
>  
> @@ -1364,22 +1359,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  			stat(s, ORDER_FALLBACK);
>  	}
>  
> -	if (kmemcheck_enabled && page
> -		&& !(s->flags & (SLAB_NOTRACK | DEBUG_DEFAULT_FLAGS))) {
> -		int pages = 1 << oo_order(oo);
> -
> -		kmemcheck_alloc_shadow(page, oo_order(oo), alloc_gfp, node);
> -
> -		/*
> -		 * Objects from caches that have a constructor don't get
> -		 * cleared when they're allocated, so we need to do it here.
> -		 */
> -		if (s->ctor)
> -			kmemcheck_mark_uninitialized_pages(page, pages);
> -		else
> -			kmemcheck_mark_unallocated_pages(page, pages);
> -	}
> -
>  	if (flags & __GFP_WAIT)
>  		local_irq_disable();
>  	if (!page)
> @@ -1466,8 +1445,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>  			check_object(s, page, p, SLUB_RED_INACTIVE);
>  	}
>  
> -	kmemcheck_free_shadow(page, compound_order(page));
> -
>  	mod_zone_page_state(page_zone(page),
>  		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
>  		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
> @@ -3329,7 +3306,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
>  	struct page *page;
>  	void *ptr = NULL;
>  
> -	flags |= __GFP_COMP | __GFP_NOTRACK;
> +	flags |= __GFP_COMP;
>  	page = alloc_kmem_pages_node(node, flags, get_order(size));
>  	if (page)
>  		ptr = page_address(page);
> @@ -5143,8 +5120,6 @@ static char *create_unique_id(struct kmem_cache *s)
>  		*p++ = 'a';
>  	if (s->flags & SLAB_DEBUG_FREE)
>  		*p++ = 'F';
> -	if (!(s->flags & SLAB_NOTRACK))
> -		*p++ = 't';
>  	if (p != name + 1)
>  		*p++ = '-';
>  	p += sprintf(p, "%07d", s->size);
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 47c3241..6d27645 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -41,7 +41,6 @@
>  #include <linux/module.h>
>  #include <linux/types.h>
>  #include <linux/kernel.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/mm.h>
>  #include <linux/interrupt.h>
>  #include <linux/in.h>
> @@ -256,14 +255,12 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>  	shinfo = skb_shinfo(skb);
>  	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
>  	atomic_set(&shinfo->dataref, 1);
> -	kmemcheck_annotate_variable(shinfo->destructor_arg);
>  
>  	if (flags & SKB_ALLOC_FCLONE) {
>  		struct sk_buff_fclones *fclones;
>  
>  		fclones = container_of(skb, struct sk_buff_fclones, skb1);
>  
> -		kmemcheck_annotate_bitfield(&fclones->skb2, flags1);
>  		skb->fclone = SKB_FCLONE_ORIG;
>  		atomic_set(&fclones->fclone_ref, 1);
>  
> @@ -324,7 +321,6 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
>  	shinfo = skb_shinfo(skb);
>  	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
>  	atomic_set(&shinfo->dataref, 1);
> -	kmemcheck_annotate_variable(shinfo->destructor_arg);
>  
>  	return skb;
>  }
> @@ -985,7 +981,6 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
>  		if (!n)
>  			return NULL;
>  
> -		kmemcheck_annotate_bitfield(n, flags1);
>  		n->fclone = SKB_FCLONE_UNAVAILABLE;
>  	}
>  
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 726e1f9..8c9b0df 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1321,8 +1321,6 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
>  		sk = kmalloc(prot->obj_size, priority);
>  
>  	if (sk != NULL) {
> -		kmemcheck_annotate_bitfield(sk, flags);
> -
>  		if (security_sk_alloc(sk, family, priority))
>  			goto out_free;
>  
> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
> index 6d592f8..afcfaf0 100644
> --- a/net/ipv4/inet_timewait_sock.c
> +++ b/net/ipv4/inet_timewait_sock.c
> @@ -9,7 +9,6 @@
>   */
>  
>  #include <linux/kernel.h>
> -#include <linux/kmemcheck.h>
>  #include <linux/slab.h>
>  #include <linux/module.h>
>  #include <net/inet_hashtables.h>
> @@ -177,8 +176,6 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
>  	if (tw != NULL) {
>  		const struct inet_sock *inet = inet_sk(sk);
>  
> -		kmemcheck_annotate_bitfield(tw, flags);
> -
>  		/* Give us an identity. */
>  		tw->tw_daddr	    = inet->inet_daddr;
>  		tw->tw_rcv_saddr    = inet->inet_rcv_saddr;
> diff --git a/net/socket.c b/net/socket.c
> index 95d3085..0b9d922 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -545,7 +545,6 @@ static struct socket *sock_alloc(void)
>  
>  	sock = SOCKET_I(inode);
>  
> -	kmemcheck_annotate_bitfield(sock, type);
>  	inode->i_ino = get_next_ino();
>  	inode->i_mode = S_IFSOCK | S_IRWXUGO;
>  	inode->i_uid = current_fsuid();
> diff --git a/scripts/kernel-doc b/scripts/kernel-doc
> index 9922e66..c69ca9e 100755
> --- a/scripts/kernel-doc
> +++ b/scripts/kernel-doc
> @@ -1750,8 +1750,6 @@ sub dump_struct($$) {
>  	# strip comments:
>  	$members =~ s/\/\*.*?\*\///gos;
>  	$nested =~ s/\/\*.*?\*\///gos;
> -	# strip kmemcheck_bitfield_{begin,end}.*;
> -	$members =~ s/kmemcheck_bitfield_.*?;//gos;
>  	# strip attributes
>  	$members =~ s/__aligned\s*\([^;]*\)//gos;
>  
> diff --git a/tools/lib/lockdep/uinclude/linux/kmemcheck.h b/tools/lib/lockdep/uinclude/linux/kmemcheck.h
> deleted file mode 100644
> index 94d598b..0000000
> --- a/tools/lib/lockdep/uinclude/linux/kmemcheck.h
> +++ /dev/null
> @@ -1,8 +0,0 @@
> -#ifndef _LIBLOCKDEP_LINUX_KMEMCHECK_H_
> -#define _LIBLOCKDEP_LINUX_KMEMCHECK_H_
> -
> -static inline void kmemcheck_mark_initialized(void *address, unsigned int n)
> -{
> -}
> -
> -#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
