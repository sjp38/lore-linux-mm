Subject: [PATCH] convert #include "linux/..." and #include "asm/..." to
	#include <...>
From: Joe Perches <joe@perches.com>
Content-Type: text/plain
Date: Fri, 24 Aug 2007 10:19:22 -0700
Message-Id: <1187975962.32738.117.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Al Viro <viro@ftp.linux.org.uk>, Jeff Dike <jdike@addtoit.com>, Christoph Lameter <clameter@sgi.com>
Cc: Chris Wright <chrisw@sous-sol.org>, David Airlie <airlied@linux.ie>, "James E.J. Bottomley" <James.Bottomley@SteelEye.com>, Jeff Dike <jdike@karaya.com>, Jeremy Fitzhardinge <jeremy@xensource.com>, Maxim Krasnyansky <maxk@qualcomm.com>, Rusty Russell <rusty@rustcorp.com.au>, Zachary Amsden <zach@vmware.com>, dri-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org, linux-scsi@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, virtualization@lists.osdl.org, vtun@office.satix.net
List-ID: <linux-mm.kvack.org>

There are several files that:

#include "linux/file" not #include <linux/file>
#include "asm/file" not #include <asm/file>

Here's the little script that converted them:

egrep -i -r -l --include=*.[ch] \
"^[[:space:]]*\#[[:space:]]*include[[:space:]]*\"(linux|asm)/(.*)\"" * \
| xargs sed -i -e 's/^[[:space:]]*#[[:space:]]*include[[:space:]]*"\(linux\|asm\)\/\(.*\)"/#include <\1\/\2>/g'

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Jeff Dike <jdike@addtoit.com>

Please pull from:

git pull git://repo.or.cz/linux-2.6/trivial-mods.git fix_includes

diffstat below:

 .../firmware_class/firmware_sample_driver.c        |    2 +-
 arch/um/drivers/daemon_kern.c                      |    8 ++--
 arch/um/drivers/hostaudio_kern.c                   |   14 +++---
 arch/um/drivers/line.c                             |   14 +++---
 arch/um/drivers/mcast_kern.c                       |   12 ++--
 arch/um/drivers/mconsole_kern.c                    |   42 +++++++-------
 arch/um/drivers/net_kern.c                         |   32 ++++++------
 arch/um/drivers/pcap_kern.c                        |    6 +-
 arch/um/drivers/port_kern.c                        |   18 +++---
 arch/um/drivers/slip_kern.c                        |   10 ++--
 arch/um/drivers/slirp_kern.c                       |   10 ++--
 arch/um/drivers/ssl.c                              |   18 +++---
 arch/um/drivers/stdio_console.c                    |   32 ++++++------
 arch/um/drivers/ubd_kern.c                         |   40 +++++++-------
 arch/um/drivers/ubd_user.c                         |    2 +-
 arch/um/include/chan_kern.h                        |    6 +-
 arch/um/include/irq_kern.h                         |    4 +-
 arch/um/include/line.h                             |   12 ++--
 arch/um/include/mconsole_kern.h                    |    2 +-
 arch/um/include/mem.h                              |    2 +-
 arch/um/include/mem_kern.h                         |    4 +-
 arch/um/include/os.h                               |    2 +-
 arch/um/include/skas/mmu-skas.h                    |    2 +-
 arch/um/include/skas/mode_kern_skas.h              |    6 +-
 arch/um/include/skas/uaccess-skas.h                |    2 +-
 arch/um/include/sysdep-i386/checksum.h             |    4 +-
 arch/um/include/sysdep-i386/syscalls.h             |    2 +-
 arch/um/include/sysdep-ppc/ptrace.h                |    2 +-
 arch/um/include/sysdep-x86_64/checksum.h           |    6 +-
 arch/um/include/tt/mode_kern_tt.h                  |    8 ++--
 arch/um/include/tt/uaccess-tt.h                    |   12 ++--
 arch/um/include/um_uaccess.h                       |    2 +-
 arch/um/kernel/exec.c                              |   16 +++---
 arch/um/kernel/exitcode.c                          |   10 ++--
 arch/um/kernel/gmon_syms.c                         |    2 +-
 arch/um/kernel/gprof_syms.c                        |    2 +-
 arch/um/kernel/init_task.c                         |   16 +++---
 arch/um/kernel/initrd.c                            |    8 ++--
 arch/um/kernel/irq.c                               |   40 +++++++-------
 arch/um/kernel/ksyms.c                             |   24 ++++----
 arch/um/kernel/mem.c                               |   24 ++++----
 arch/um/kernel/physmem.c                           |   18 +++---
 arch/um/kernel/process.c                           |   56 ++++++++++----------
 arch/um/kernel/ptrace.c                            |   20 ++++----
 arch/um/kernel/reboot.c                            |    6 +-
 arch/um/kernel/sigio.c                             |   10 ++--
 arch/um/kernel/signal.c                            |   30 +++++-----
 arch/um/kernel/skas/exec.c                         |   14 +++---
 arch/um/kernel/skas/mem.c                          |    4 +-
 arch/um/kernel/skas/mmu.c                          |   24 ++++----
 arch/um/kernel/skas/process.c                      |   18 +++---
 arch/um/kernel/skas/syscall.c                      |   12 ++--
 arch/um/kernel/skas/tlb.c                          |   12 ++--
 arch/um/kernel/skas/uaccess.c                      |   20 ++++----
 arch/um/kernel/smp.c                               |   24 ++++----
 arch/um/kernel/syscall.c                           |   30 +++++-----
 arch/um/kernel/sysrq.c                             |   12 ++--
 arch/um/kernel/time.c                              |   28 +++++-----
 arch/um/kernel/tlb.c                               |   10 ++--
 arch/um/kernel/trap.c                              |   28 +++++-----
 arch/um/kernel/tt/exec_kern.c                      |   14 +++---
 arch/um/kernel/tt/gdb_kern.c                       |    2 +-
 arch/um/kernel/tt/ksyms.c                          |    4 +-
 arch/um/kernel/tt/mem.c                            |    6 +-
 arch/um/kernel/tt/process_kern.c                   |   18 +++---
 arch/um/kernel/tt/syscall_kern.c                   |   16 +++---
 arch/um/kernel/tt/tlb.c                            |   16 +++---
 arch/um/kernel/tt/uaccess.c                        |    4 +-
 arch/um/kernel/um_arch.c                           |   44 ++++++++--------
 arch/um/kernel/umid.c                              |    4 +-
 arch/um/os-Linux/drivers/ethertap_kern.c           |    6 +-
 arch/um/os-Linux/drivers/tuntap_kern.c             |   12 ++--
 arch/um/os-Linux/tls.c                             |    2 +-
 arch/um/os-Linux/user_syms.c                       |    4 +-
 arch/um/os-Linux/util.c                            |    2 +-
 arch/um/sys-i386/ksyms.c                           |   18 +++---
 arch/um/sys-i386/ldt.c                             |   20 ++++----
 arch/um/sys-i386/ptrace.c                          |   12 ++--
 arch/um/sys-i386/signal.c                          |   12 ++--
 arch/um/sys-i386/syscalls.c                        |   12 ++--
 arch/um/sys-i386/sysrq.c                           |   10 ++--
 arch/um/sys-i386/tls.c                             |   18 +++---
 arch/um/sys-ppc/miscthings.c                       |    6 +-
 arch/um/sys-ppc/ptrace.c                           |    4 +-
 arch/um/sys-ppc/sigcontext.c                       |    4 +-
 arch/um/sys-ppc/sysrq.c                            |    6 +-
 arch/um/sys-x86_64/ksyms.c                         |   16 +++---
 arch/um/sys-x86_64/mem.c                           |    6 +-
 arch/um/sys-x86_64/signal.c                        |   18 +++---
 arch/um/sys-x86_64/syscalls.c                      |   18 +++---
 arch/um/sys-x86_64/sysrq.c                         |   10 ++--
 arch/um/sys-x86_64/tls.c                           |    2 +-
 drivers/char/drm/drm_ioctl.c                       |    2 +-
 drivers/char/pcmcia/synclink_cs.c                  |    2 +-
 drivers/char/synclink.c                            |    2 +-
 drivers/char/synclink_gt.c                         |    2 +-
 drivers/char/synclinkmp.c                          |    2 +-
 drivers/scsi/aic94xx/aic94xx_dump.c                |    2 +-
 include/asm-arm/plat-s3c/uncompress.h              |    4 +-
 include/asm-arm/proc-fns.h                         |    4 +-
 include/asm-i386/mutex.h                           |    2 +-
 include/asm-um/a.out.h                             |    2 +-
 include/asm-um/alternative.h                       |    2 +-
 include/asm-um/atomic.h                            |    4 +-
 include/asm-um/bitops.h                            |    2 +-
 include/asm-um/boot.h                              |    2 +-
 include/asm-um/byteorder.h                         |    2 +-
 include/asm-um/cacheflush.h                        |    2 +-
 include/asm-um/calling.h                           |    2 +-
 include/asm-um/cmpxchg.h                           |    2 +-
 include/asm-um/cobalt.h                            |    2 +-
 include/asm-um/cpufeature.h                        |    2 +-
 include/asm-um/current.h                           |    4 +-
 include/asm-um/div64.h                             |    2 +-
 include/asm-um/dma.h                               |    2 +-
 include/asm-um/dwarf2.h                            |    2 +-
 include/asm-um/errno.h                             |    2 +-
 include/asm-um/fcntl.h                             |    2 +-
 include/asm-um/floppy.h                            |    2 +-
 include/asm-um/highmem.h                           |    6 +-
 include/asm-um/host_ldt-i386.h                     |    2 +-
 include/asm-um/host_ldt-x86_64.h                   |    2 +-
 include/asm-um/hw_irq.h                            |    4 +-
 include/asm-um/ide.h                               |    2 +-
 include/asm-um/io.h                                |    2 +-
 include/asm-um/ioctl.h                             |    2 +-
 include/asm-um/ioctls.h                            |    2 +-
 include/asm-um/ipcbuf.h                            |    2 +-
 include/asm-um/keyboard.h                          |    2 +-
 include/asm-um/ldt.h                               |    4 +-
 include/asm-um/linkage.h                           |    2 +-
 include/asm-um/local.h                             |    2 +-
 include/asm-um/locks.h                             |    2 +-
 include/asm-um/mca_dma.h                           |    2 +-
 include/asm-um/mman.h                              |    2 +-
 include/asm-um/mmu_context.h                       |    2 +-
 include/asm-um/module-generic.h                    |    2 +-
 include/asm-um/msgbuf.h                            |    2 +-
 include/asm-um/mtrr.h                              |    2 +-
 include/asm-um/namei.h                             |    2 +-
 include/asm-um/paravirt.h                          |    2 +-
 include/asm-um/percpu.h                            |    2 +-
 include/asm-um/pgalloc.h                           |    4 +-
 include/asm-um/pgtable.h                           |   14 +++---
 include/asm-um/poll.h                              |    2 +-
 include/asm-um/posix_types.h                       |    2 +-
 include/asm-um/prctl.h                             |    2 +-
 include/asm-um/processor-generic.h                 |    2 +-
 include/asm-um/processor-i386.h                    |   10 ++--
 include/asm-um/processor-ppc.h                     |    2 +-
 include/asm-um/processor-x86_64.h                  |    4 +-
 include/asm-um/ptrace-generic.h                    |    2 +-
 include/asm-um/ptrace-i386.h                       |    6 +-
 include/asm-um/ptrace-x86_64.h                     |    8 ++--
 include/asm-um/resource.h                          |    2 +-
 include/asm-um/rwlock.h                            |    2 +-
 include/asm-um/rwsem.h                             |    2 +-
 include/asm-um/scatterlist.h                       |    2 +-
 include/asm-um/semaphore.h                         |    2 +-
 include/asm-um/sembuf.h                            |    2 +-
 include/asm-um/serial.h                            |    2 +-
 include/asm-um/shmbuf.h                            |    2 +-
 include/asm-um/shmparam.h                          |    2 +-
 include/asm-um/sigcontext-generic.h                |    2 +-
 include/asm-um/sigcontext-i386.h                   |    2 +-
 include/asm-um/sigcontext-ppc.h                    |    2 +-
 include/asm-um/sigcontext-x86_64.h                 |    2 +-
 include/asm-um/siginfo.h                           |    2 +-
 include/asm-um/signal.h                            |    2 +-
 include/asm-um/smp.h                               |    6 +-
 include/asm-um/socket.h                            |    2 +-
 include/asm-um/sockios.h                           |    2 +-
 include/asm-um/spinlock.h                          |    2 +-
 include/asm-um/spinlock_types.h                    |    2 +-
 include/asm-um/stat.h                              |    2 +-
 include/asm-um/statfs.h                            |    2 +-
 include/asm-um/string.h                            |    4 +-
 include/asm-um/system-generic.h                    |    2 +-
 include/asm-um/system-i386.h                       |    2 +-
 include/asm-um/system-ppc.h                        |    4 +-
 include/asm-um/system-x86_64.h                     |    2 +-
 include/asm-um/termbits.h                          |    2 +-
 include/asm-um/termios.h                           |    2 +-
 include/asm-um/types.h                             |    2 +-
 include/asm-um/uaccess.h                           |    2 +-
 include/asm-um/ucontext.h                          |    2 +-
 include/asm-um/unaligned.h                         |    2 +-
 include/asm-um/unistd.h                            |    6 +-
 include/asm-um/user.h                              |    2 +-
 include/asm-um/vga.h                               |    2 +-
 include/asm-um/vm86.h                              |    2 +-
 mm/slab.c                                          |    2 +-
 192 files changed, 732 insertions(+), 732 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
