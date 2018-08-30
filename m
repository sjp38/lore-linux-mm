Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C62F6B5144
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:41:42 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id m28-v6so5744013wrf.14
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 04:41:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a12-v6sor49826wmb.16.2018.08.30.04.41.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 04:41:38 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v6 11/11] arm64: annotate user pointers casts detected by sparse
Date: Thu, 30 Aug 2018 13:41:16 +0200
Message-Id: <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
In-Reply-To: <cover.1535629099.git.andreyknvl@google.com>
References: <cover.1535629099.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>

This patch adds __force annotations for __user pointers casts detected by
sparse with the -Wcast-from-as flag enabled (added in [1]).

[1] https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/compat.h               |  2 +-
 arch/arm64/include/asm/uaccess.h              |  4 +--
 arch/arm64/kernel/perf_callchain.c            |  4 +--
 arch/arm64/kernel/signal.c                    | 16 +++++-----
 arch/arm64/kernel/signal32.c                  |  6 ++--
 arch/arm64/mm/fault.c                         |  2 +-
 block/compat_ioctl.c                          | 15 +++++----
 drivers/ata/libata-scsi.c                     |  2 +-
 drivers/block/loop.c                          |  2 +-
 drivers/gpio/gpiolib.c                        |  8 +++--
 drivers/input/evdev.c                         |  2 +-
 drivers/media/dvb-core/dvb_frontend.c         |  3 +-
 drivers/media/v4l2-core/v4l2-compat-ioctl32.c |  9 +++---
 drivers/mmc/core/block.c                      |  6 ++--
 drivers/mtd/mtdchar.c                         |  2 +-
 drivers/net/tap.c                             |  2 +-
 drivers/net/tun.c                             |  2 +-
 drivers/spi/spidev.c                          |  6 ++--
 drivers/tty/tty_ioctl.c                       |  3 +-
 drivers/tty/vt/vt_ioctl.c                     |  5 +--
 drivers/usb/core/devio.c                      |  8 +++--
 drivers/vfio/vfio.c                           |  6 ++--
 drivers/video/fbdev/core/fbmem.c              |  4 +--
 drivers/xen/gntdev.c                          |  6 ++--
 drivers/xen/privcmd.c                         |  4 +--
 fs/aio.c                                      |  2 +-
 fs/autofs/dev-ioctl.c                         |  3 +-
 fs/autofs/root.c                              |  2 +-
 fs/binfmt_elf.c                               | 10 +++---
 fs/btrfs/ioctl.c                              |  2 +-
 fs/compat_ioctl.c                             | 32 ++++++++++---------
 fs/ext2/ioctl.c                               |  2 +-
 fs/ext4/ioctl.c                               |  2 +-
 fs/fat/file.c                                 |  3 +-
 fs/fuse/file.c                                |  2 +-
 fs/namespace.c                                |  2 +-
 fs/readdir.c                                  |  4 +--
 fs/signalfd.c                                 | 10 +++---
 include/linux/mm.h                            |  2 +-
 include/linux/pagemap.h                       |  8 ++---
 include/linux/socket.h                        |  2 +-
 ipc/shm.c                                     |  4 +--
 kernel/futex.c                                |  6 ++--
 kernel/futex_compat.c                         |  2 +-
 kernel/power/user.c                           |  2 +-
 kernel/signal.c                               |  2 +-
 lib/iov_iter.c                                | 16 +++++-----
 lib/strncpy_from_user.c                       |  2 +-
 lib/strnlen_user.c                            |  4 +--
 lib/test_kasan.c                              |  2 +-
 mm/memory.c                                   |  2 +-
 mm/migrate.c                                  |  4 +--
 mm/process_vm_access.c                        | 13 ++++----
 net/bluetooth/hidp/sock.c                     |  2 +-
 net/compat.c                                  | 12 ++++---
 sound/core/control_compat.c                   |  5 +--
 sound/core/pcm_native.c                       |  5 +--
 sound/core/timer_compat.c                     |  3 +-
 58 files changed, 163 insertions(+), 140 deletions(-)

diff --git a/arch/arm64/include/asm/compat.h b/arch/arm64/include/asm/compat.h
index 1a037b94eba1..66e023fcea0a 100644
--- a/arch/arm64/include/asm/compat.h
+++ b/arch/arm64/include/asm/compat.h
@@ -155,7 +155,7 @@ static inline void __user *compat_ptr(compat_uptr_t uptr)
 
 static inline compat_uptr_t ptr_to_compat(void __user *uptr)
 {
-	return (u32)(unsigned long)uptr;
+	return (u32)(__force unsigned long)uptr;
 }
 
 #define compat_user_stack_pointer() (user_stack_pointer(task_pt_regs(current)))
diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
index fa7318d3d7d5..9b22c0be5c0b 100644
--- a/arch/arm64/include/asm/uaccess.h
+++ b/arch/arm64/include/asm/uaccess.h
@@ -76,7 +76,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
 {
 	unsigned long ret, limit = current_thread_info()->addr_limit;
 
-	__chk_user_ptr(addr);
+	__chk_user_ptr((void __force *)addr);
 	asm volatile(
 	// A + B <= C + 1 for all A,B,C, in four easy steps:
 	// 1: X = A + B; X' = X % 2^64
@@ -103,7 +103,7 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
  * pass on to access_ok(), for instance.
  */
 #define untagged_addr(addr)		\
-	((__typeof__(addr))sign_extend64((__u64)(addr), 55))
+	((__typeof__(addr))sign_extend64((__force __u64)(addr), 55))
 
 #define access_ok(type, addr, size)	\
 	__range_ok(untagged_addr(addr), size)
diff --git a/arch/arm64/kernel/perf_callchain.c b/arch/arm64/kernel/perf_callchain.c
index bcafd7dcfe8b..e2d781b9e7ea 100644
--- a/arch/arm64/kernel/perf_callchain.c
+++ b/arch/arm64/kernel/perf_callchain.c
@@ -123,7 +123,7 @@ void perf_callchain_user(struct perf_callchain_entry_ctx *entry,
 		tail = (struct frame_tail __user *)regs->regs[29];
 
 		while (entry->nr < entry->max_stack &&
-		       tail && !((unsigned long)tail & 0xf))
+		       tail && !((__force unsigned long)tail & 0xf))
 			tail = user_backtrace(tail, entry);
 	} else {
 #ifdef CONFIG_COMPAT
@@ -133,7 +133,7 @@ void perf_callchain_user(struct perf_callchain_entry_ctx *entry,
 		tail = (struct compat_frame_tail __user *)regs->compat_fp - 1;
 
 		while ((entry->nr < entry->max_stack) &&
-			tail && !((unsigned long)tail & 0x3))
+			tail && !((__force unsigned long)tail & 0x3))
 			tail = compat_user_backtrace(tail, entry);
 #endif
 	}
diff --git a/arch/arm64/kernel/signal.c b/arch/arm64/kernel/signal.c
index 5dcc942906db..da67d0bd1628 100644
--- a/arch/arm64/kernel/signal.c
+++ b/arch/arm64/kernel/signal.c
@@ -351,7 +351,7 @@ static int parse_user_sigframe(struct user_ctxs *user,
 	user->fpsimd = NULL;
 	user->sve = NULL;
 
-	if (!IS_ALIGNED((unsigned long)base, 16))
+	if (!IS_ALIGNED((__force unsigned long)base, 16))
 		goto invalid;
 
 	while (1) {
@@ -450,7 +450,7 @@ static int parse_user_sigframe(struct user_ctxs *user,
 			have_extra_context = true;
 
 			base = (__force void __user *)extra_datap;
-			if (!IS_ALIGNED((unsigned long)base, 16))
+			if (!IS_ALIGNED((__force unsigned long)base, 16))
 				goto invalid;
 
 			if (!IS_ALIGNED(extra_size, 16))
@@ -742,16 +742,16 @@ static void setup_return(struct pt_regs *regs, struct k_sigaction *ka,
 	__sigrestore_t sigtramp;
 
 	regs->regs[0] = usig;
-	regs->sp = (unsigned long)user->sigframe;
-	regs->regs[29] = (unsigned long)&user->next_frame->fp;
-	regs->pc = (unsigned long)ka->sa.sa_handler;
+	regs->sp = (__force unsigned long)user->sigframe;
+	regs->regs[29] = (__force unsigned long)&user->next_frame->fp;
+	regs->pc = (__force unsigned long)ka->sa.sa_handler;
 
 	if (ka->sa.sa_flags & SA_RESTORER)
 		sigtramp = ka->sa.sa_restorer;
 	else
 		sigtramp = VDSO_SYMBOL(current->mm->context.vdso, sigtramp);
 
-	regs->regs[30] = (unsigned long)sigtramp;
+	regs->regs[30] = (__force unsigned long)sigtramp;
 }
 
 static int setup_rt_frame(int usig, struct ksignal *ksig, sigset_t *set,
@@ -777,8 +777,8 @@ static int setup_rt_frame(int usig, struct ksignal *ksig, sigset_t *set,
 		setup_return(regs, &ksig->ka, &user, usig);
 		if (ksig->ka.sa.sa_flags & SA_SIGINFO) {
 			err |= copy_siginfo_to_user(&frame->info, &ksig->info);
-			regs->regs[1] = (unsigned long)&frame->info;
-			regs->regs[2] = (unsigned long)&frame->uc;
+			regs->regs[1] = (__force unsigned long)&frame->info;
+			regs->regs[2] = (__force unsigned long)&frame->uc;
 		}
 	}
 
diff --git a/arch/arm64/kernel/signal32.c b/arch/arm64/kernel/signal32.c
index 24b09003f821..184178a552d6 100644
--- a/arch/arm64/kernel/signal32.c
+++ b/arch/arm64/kernel/signal32.c
@@ -483,8 +483,10 @@ int compat_setup_rt_frame(int usig, struct ksignal *ksig,
 
 	if (err == 0) {
 		compat_setup_return(regs, &ksig->ka, frame->sig.retcode, frame, usig);
-		regs->regs[1] = (compat_ulong_t)(unsigned long)&frame->info;
-		regs->regs[2] = (compat_ulong_t)(unsigned long)&frame->sig.uc;
+		regs->regs[1] =
+			(compat_ulong_t)(__force unsigned long)&frame->info;
+		regs->regs[2] =
+			(compat_ulong_t)(__force unsigned long)&frame->sig.uc;
 	}
 
 	return err;
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 871fb3c38b23..0978b838f46e 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -299,7 +299,7 @@ static void __do_kernel_fault(unsigned long addr, unsigned int esr,
 
 static void __do_user_fault(struct siginfo *info, unsigned int esr)
 {
-	current->thread.fault_address = (unsigned long)info->si_addr;
+	current->thread.fault_address = (__force unsigned long)info->si_addr;
 
 	/*
 	 * If the faulting address is in the kernel, we must sanitize the ESR.
diff --git a/block/compat_ioctl.c b/block/compat_ioctl.c
index 6ca015f92766..35aa46e0e289 100644
--- a/block/compat_ioctl.c
+++ b/block/compat_ioctl.c
@@ -85,7 +85,7 @@ static int compat_hdio_ioctl(struct block_device *bdev, fmode_t mode,
 
 	p = compat_alloc_user_space(sizeof(unsigned long));
 	error = __blkdev_driver_ioctl(bdev, mode,
-				cmd, (unsigned long)p);
+				cmd, (__force unsigned long)p);
 	if (error == 0) {
 		unsigned int __user *uvp = compat_ptr(arg);
 		unsigned long v;
@@ -138,7 +138,7 @@ static int compat_cdrom_read_audio(struct block_device *bdev, fmode_t mode,
 		return -EFAULT;
 
 	return __blkdev_driver_ioctl(bdev, mode, cmd,
-			(unsigned long)cdread_audio);
+			(__force unsigned long)cdread_audio);
 }
 
 static int compat_cdrom_generic_command(struct block_device *bdev, fmode_t mode,
@@ -170,7 +170,8 @@ static int compat_cdrom_generic_command(struct block_device *bdev, fmode_t mode,
 	    put_user(compat_ptr(data), &cgc->reserved[0]))
 		return -EFAULT;
 
-	return __blkdev_driver_ioctl(bdev, mode, cmd, (unsigned long)cgc);
+	return __blkdev_driver_ioctl(bdev, mode, cmd,
+			(__force unsigned long)cgc);
 }
 
 struct compat_blkpg_ioctl_arg {
@@ -199,7 +200,7 @@ static int compat_blkpg_ioctl(struct block_device *bdev, fmode_t mode,
 	if (err)
 		return err;
 
-	return blkdev_ioctl(bdev, mode, cmd, (unsigned long)a);
+	return blkdev_ioctl(bdev, mode, cmd, (__force unsigned long)a);
 }
 
 #define BLKBSZGET_32		_IOR(0x12, 112, int)
@@ -276,7 +277,7 @@ static int compat_blkdev_driver_ioctl(struct block_device *bdev, fmode_t mode,
 	case DVD_READ_STRUCT:
 	case DVD_WRITE_STRUCT:
 	case DVD_AUTH:
-		arg = (unsigned long)compat_ptr(arg);
+		arg = (__force unsigned long)compat_ptr(arg);
 	/* These intepret arg as an unsigned long, not as a pointer,
 	 * so we must not do compat_ptr() conversion. */
 	case HDIO_SET_MULTCOUNT:
@@ -355,10 +356,10 @@ long compat_blkdev_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 	 */
 	case BLKRRPART:
 		return blkdev_ioctl(bdev, mode, cmd,
-				(unsigned long)compat_ptr(arg));
+				(__force unsigned long)compat_ptr(arg));
 	case BLKBSZSET_32:
 		return blkdev_ioctl(bdev, mode, BLKBSZSET,
-				(unsigned long)compat_ptr(arg));
+				(__force unsigned long)compat_ptr(arg));
 	case BLKPG:
 		return compat_blkpg_ioctl(bdev, mode, cmd, compat_ptr(arg));
 	case BLKRAGET:
diff --git a/drivers/ata/libata-scsi.c b/drivers/ata/libata-scsi.c
index 1984fc78c750..9d4528ec8b43 100644
--- a/drivers/ata/libata-scsi.c
+++ b/drivers/ata/libata-scsi.c
@@ -792,7 +792,7 @@ int ata_sas_scsi_ioctl(struct ata_port *ap, struct scsi_device *scsidev,
 		return put_user(val, (unsigned long __user *)arg);
 
 	case HDIO_SET_32BIT:
-		val = (unsigned long) arg;
+		val = (__force unsigned long) arg;
 		rc = 0;
 		spin_lock_irqsave(ap->lock, flags);
 		if (ap->pflags & ATA_PFLAG_PIO32CHANGE) {
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index ea9debf59b22..910f7910ab12 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -1608,7 +1608,7 @@ static int lo_compat_ioctl(struct block_device *bdev, fmode_t mode,
 	case LOOP_CLR_FD:
 	case LOOP_GET_STATUS64:
 	case LOOP_SET_STATUS64:
-		arg = (unsigned long) compat_ptr(arg);
+		arg = (__force unsigned long) compat_ptr(arg);
 		/* fall through */
 	case LOOP_SET_FD:
 	case LOOP_CHANGE_FD:
diff --git a/drivers/gpio/gpiolib.c b/drivers/gpio/gpiolib.c
index e8f8a1999393..1f678dffe159 100644
--- a/drivers/gpio/gpiolib.c
+++ b/drivers/gpio/gpiolib.c
@@ -477,7 +477,8 @@ static long linehandle_ioctl(struct file *filep, unsigned int cmd,
 static long linehandle_ioctl_compat(struct file *filep, unsigned int cmd,
 			     unsigned long arg)
 {
-	return linehandle_ioctl(filep, cmd, (unsigned long)compat_ptr(arg));
+	return linehandle_ioctl(filep, cmd,
+				(__force unsigned long)compat_ptr(arg));
 }
 #endif
 
@@ -792,7 +793,8 @@ static long lineevent_ioctl(struct file *filep, unsigned int cmd,
 static long lineevent_ioctl_compat(struct file *filep, unsigned int cmd,
 				   unsigned long arg)
 {
-	return lineevent_ioctl(filep, cmd, (unsigned long)compat_ptr(arg));
+	return lineevent_ioctl(filep, cmd,
+				(__force unsigned long)compat_ptr(arg));
 }
 #endif
 
@@ -1091,7 +1093,7 @@ static long gpio_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 static long gpio_ioctl_compat(struct file *filp, unsigned int cmd,
 			      unsigned long arg)
 {
-	return gpio_ioctl(filp, cmd, (unsigned long)compat_ptr(arg));
+	return gpio_ioctl(filp, cmd, (__force unsigned long)compat_ptr(arg));
 }
 #endif
 
diff --git a/drivers/input/evdev.c b/drivers/input/evdev.c
index 370206f987f9..61947c834e01 100644
--- a/drivers/input/evdev.c
+++ b/drivers/input/evdev.c
@@ -1108,7 +1108,7 @@ static long evdev_do_ioctl(struct file *file, unsigned int cmd,
 		return 0;
 
 	case EVIOCRMFF:
-		return input_ff_erase(dev, (int)(unsigned long) p, file);
+		return input_ff_erase(dev, (int)(__force unsigned long)p, file);
 
 	case EVIOCGEFFECTS:
 		i = test_bit(EV_FF, dev->evbit) ?
diff --git a/drivers/media/dvb-core/dvb_frontend.c b/drivers/media/dvb-core/dvb_frontend.c
index c4e7ebfe4d29..ec97b26cbd72 100644
--- a/drivers/media/dvb-core/dvb_frontend.c
+++ b/drivers/media/dvb-core/dvb_frontend.c
@@ -2180,7 +2180,8 @@ static long dvb_frontend_compat_ioctl(struct file *file, unsigned int cmd,
 		return err;
 	}
 
-	return dvb_frontend_ioctl(file, cmd, (unsigned long)compat_ptr(arg));
+	return dvb_frontend_ioctl(file, cmd,
+			(__force unsigned long)compat_ptr(arg));
 }
 #endif
 
diff --git a/drivers/media/v4l2-core/v4l2-compat-ioctl32.c b/drivers/media/v4l2-core/v4l2-compat-ioctl32.c
index 6481212fda77..97a4e84e2070 100644
--- a/drivers/media/v4l2-core/v4l2-compat-ioctl32.c
+++ b/drivers/media/v4l2-core/v4l2-compat-ioctl32.c
@@ -505,7 +505,8 @@ static int get_v4l2_plane32(struct v4l2_plane __user *p64,
 		break;
 	case V4L2_MEMORY_USERPTR:
 		if (get_user(p, &p32->m.userptr) ||
-		    put_user((unsigned long)compat_ptr(p), &p64->m.userptr))
+		    put_user((__force unsigned long)compat_ptr(p),
+				&p64->m.userptr))
 			return -EFAULT;
 		break;
 	case V4L2_MEMORY_DMABUF:
@@ -657,7 +658,7 @@ static int get_v4l2_buffer32(struct v4l2_buffer __user *p64,
 			compat_ulong_t userptr;
 
 			if (get_user(userptr, &p32->m.userptr) ||
-			    put_user((unsigned long)compat_ptr(userptr),
+			    put_user((__force unsigned long)compat_ptr(userptr),
 				     &p64->m.userptr))
 				return -EFAULT;
 			break;
@@ -1340,9 +1341,9 @@ static long do_video_ioctl(struct file *file, unsigned int cmd, unsigned long ar
 	 * Otherwise, it will pass the newly allocated @new_p64 argument.
 	 */
 	if (compatible_arg)
-		err = native_ioctl(file, cmd, (unsigned long)p32);
+		err = native_ioctl(file, cmd, (__force unsigned long)p32);
 	else
-		err = native_ioctl(file, cmd, (unsigned long)new_p64);
+		err = native_ioctl(file, cmd, (__force unsigned long)new_p64);
 
 	if (err == -ENOTTY)
 		return err;
diff --git a/drivers/mmc/core/block.c b/drivers/mmc/core/block.c
index a0b9102c4c6e..eb2c21b55fe6 100644
--- a/drivers/mmc/core/block.c
+++ b/drivers/mmc/core/block.c
@@ -799,7 +799,8 @@ static int mmc_blk_ioctl(struct block_device *bdev, fmode_t mode,
 static int mmc_blk_compat_ioctl(struct block_device *bdev, fmode_t mode,
 	unsigned int cmd, unsigned long arg)
 {
-	return mmc_blk_ioctl(bdev, mode, cmd, (unsigned long) compat_ptr(arg));
+	return mmc_blk_ioctl(bdev, mode, cmd,
+			(__force unsigned long) compat_ptr(arg));
 }
 #endif
 
@@ -2491,7 +2492,8 @@ static long mmc_rpmb_ioctl(struct file *filp, unsigned int cmd,
 static long mmc_rpmb_ioctl_compat(struct file *filp, unsigned int cmd,
 			      unsigned long arg)
 {
-	return mmc_rpmb_ioctl(filp, cmd, (unsigned long)compat_ptr(arg));
+	return mmc_rpmb_ioctl(filp, cmd,
+			(__force unsigned long)compat_ptr(arg));
 }
 #endif
 
diff --git a/drivers/mtd/mtdchar.c b/drivers/mtd/mtdchar.c
index 02389528f622..d493647821d5 100644
--- a/drivers/mtd/mtdchar.c
+++ b/drivers/mtd/mtdchar.c
@@ -1090,7 +1090,7 @@ static long mtdchar_compat_ioctl(struct file *file, unsigned int cmd,
 	}
 
 	default:
-		ret = mtdchar_ioctl(file, cmd, (unsigned long)argp);
+		ret = mtdchar_ioctl(file, cmd, (__force unsigned long)argp);
 	}
 
 	mutex_unlock(&mtd_mutex);
diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index f0f7cd977667..eb710bc2d19d 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -1128,7 +1128,7 @@ static long tap_ioctl(struct file *file, unsigned int cmd,
 static long tap_compat_ioctl(struct file *file, unsigned int cmd,
 			     unsigned long arg)
 {
-	return tap_ioctl(file, cmd, (unsigned long)compat_ptr(arg));
+	return tap_ioctl(file, cmd, (__force unsigned long)compat_ptr(arg));
 }
 #endif
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ebd07ad82431..29be50de0d3d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -3191,7 +3191,7 @@ static long tun_chr_compat_ioctl(struct file *file,
 	case TUNSETSNDBUF:
 	case SIOCGIFHWADDR:
 	case SIOCSIFHWADDR:
-		arg = (unsigned long)compat_ptr(arg);
+		arg = (__force unsigned long)compat_ptr(arg);
 		break;
 	default:
 		arg = (compat_ulong_t)arg;
diff --git a/drivers/spi/spidev.c b/drivers/spi/spidev.c
index cda10719d1d1..d9a91676a406 100644
--- a/drivers/spi/spidev.c
+++ b/drivers/spi/spidev.c
@@ -524,8 +524,8 @@ spidev_compat_ioc_message(struct file *filp, unsigned int cmd,
 
 	/* Convert buffer pointers */
 	for (n = 0; n < n_ioc; n++) {
-		ioc[n].rx_buf = (uintptr_t) compat_ptr(ioc[n].rx_buf);
-		ioc[n].tx_buf = (uintptr_t) compat_ptr(ioc[n].tx_buf);
+		ioc[n].rx_buf = (__force uintptr_t) compat_ptr(ioc[n].rx_buf);
+		ioc[n].tx_buf = (__force uintptr_t) compat_ptr(ioc[n].tx_buf);
 	}
 
 	/* translate to spi_message, execute */
@@ -546,7 +546,7 @@ spidev_compat_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 			&& _IOC_DIR(cmd) == _IOC_WRITE)
 		return spidev_compat_ioc_message(filp, cmd, arg);
 
-	return spidev_ioctl(filp, cmd, (unsigned long)compat_ptr(arg));
+	return spidev_ioctl(filp, cmd, (__force unsigned long)compat_ptr(arg));
 }
 #else
 #define spidev_compat_ioctl NULL
diff --git a/drivers/tty/tty_ioctl.c b/drivers/tty/tty_ioctl.c
index d99fec44036c..5abd148bb459 100644
--- a/drivers/tty/tty_ioctl.c
+++ b/drivers/tty/tty_ioctl.c
@@ -949,7 +949,8 @@ long n_tty_compat_ioctl_helper(struct tty_struct *tty, struct file *file,
 	switch (cmd) {
 	case TIOCGLCKTRMIOS:
 	case TIOCSLCKTRMIOS:
-		return tty_mode_ioctl(tty, file, cmd, (unsigned long) compat_ptr(arg));
+		return tty_mode_ioctl(tty, file, cmd,
+				(__force unsigned long) compat_ptr(arg));
 	default:
 		return -ENOIOCTLCMD;
 	}
diff --git a/drivers/tty/vt/vt_ioctl.c b/drivers/tty/vt/vt_ioctl.c
index a78ad10a119b..794445d10965 100644
--- a/drivers/tty/vt/vt_ioctl.c
+++ b/drivers/tty/vt/vt_ioctl.c
@@ -1132,7 +1132,8 @@ compat_kdfontop_ioctl(struct compat_console_font_op __user *fontop,
 	i = con_font_op(vc, op);
 	if (i)
 		return i;
-	((struct compat_console_font_op *)op)->data = (unsigned long)op->data;
+	((struct compat_console_font_op *)op)->data =
+					(__force unsigned long)op->data;
 	if (copy_to_user(fontop, op, sizeof(struct compat_console_font_op)))
 		return -EFAULT;
 	return 0;
@@ -1239,7 +1240,7 @@ long vt_compat_ioctl(struct tty_struct *tty,
 	 * but we have to convert it to a proper 64 bit pointer.
 	 */
 	default:
-		arg = (unsigned long)compat_ptr(arg);
+		arg = (__force unsigned long)compat_ptr(arg);
 		goto fallback;
 	}
 out:
diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
index ed5ab7c8100b..e2fd6ca2d7a3 100644
--- a/drivers/usb/core/devio.c
+++ b/drivers/usb/core/devio.c
@@ -1405,7 +1405,8 @@ find_memory_area(struct usb_dev_state *ps, const struct usbdevfs_urb *uurb)
 {
 	struct usb_memory *usbm = NULL, *iter;
 	unsigned long flags;
-	unsigned long uurb_start = (unsigned long)untagged_addr(uurb->buffer);
+	unsigned long uurb_start =
+		(__force unsigned long)untagged_addr(uurb->buffer);
 
 	spin_lock_irqsave(&ps->lock, flags);
 	list_for_each_entry(iter, &ps->memory_list, memlist) {
@@ -1635,7 +1636,8 @@ static int proc_do_submiturb(struct usb_dev_state *ps, struct usbdevfs_urb *uurb
 	} else if (uurb->buffer_length > 0) {
 		if (as->usbm) {
 			unsigned long uurb_start =
-				(unsigned long)untagged_addr(uurb->buffer);
+				(__force unsigned long)untagged_addr(
+								uurb->buffer);
 
 			as->urb->transfer_buffer = as->usbm->mem +
 					(uurb_start - as->usbm->vm_start);
@@ -1715,7 +1717,7 @@ static int proc_do_submiturb(struct usb_dev_state *ps, struct usbdevfs_urb *uurb
 	as->userurb = arg;
 	if (as->usbm) {
 		unsigned long uurb_start =
-			(unsigned long)untagged_addr(uurb->buffer);
+			(__force unsigned long)untagged_addr(uurb->buffer);
 
 		as->urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
 		as->urb->transfer_dma = as->usbm->dma_handle +
diff --git a/drivers/vfio/vfio.c b/drivers/vfio/vfio.c
index 64833879f75d..8f69175eba0e 100644
--- a/drivers/vfio/vfio.c
+++ b/drivers/vfio/vfio.c
@@ -1204,7 +1204,7 @@ static long vfio_fops_unl_ioctl(struct file *filep,
 static long vfio_fops_compat_ioctl(struct file *filep,
 				   unsigned int cmd, unsigned long arg)
 {
-	arg = (unsigned long)compat_ptr(arg);
+	arg = (__force unsigned long)compat_ptr(arg);
 	return vfio_fops_unl_ioctl(filep, cmd, arg);
 }
 #endif	/* CONFIG_COMPAT */
@@ -1576,7 +1576,7 @@ static long vfio_group_fops_unl_ioctl(struct file *filep,
 static long vfio_group_fops_compat_ioctl(struct file *filep,
 					 unsigned int cmd, unsigned long arg)
 {
-	arg = (unsigned long)compat_ptr(arg);
+	arg = (__force unsigned long)compat_ptr(arg);
 	return vfio_group_fops_unl_ioctl(filep, cmd, arg);
 }
 #endif	/* CONFIG_COMPAT */
@@ -1707,7 +1707,7 @@ static int vfio_device_fops_mmap(struct file *filep, struct vm_area_struct *vma)
 static long vfio_device_fops_compat_ioctl(struct file *filep,
 					  unsigned int cmd, unsigned long arg)
 {
-	arg = (unsigned long)compat_ptr(arg);
+	arg = (__force unsigned long)compat_ptr(arg);
 	return vfio_device_fops_unl_ioctl(filep, cmd, arg);
 }
 #endif	/* CONFIG_COMPAT */
diff --git a/drivers/video/fbdev/core/fbmem.c b/drivers/video/fbdev/core/fbmem.c
index 20405421a5ed..a267f41378c9 100644
--- a/drivers/video/fbdev/core/fbmem.c
+++ b/drivers/video/fbdev/core/fbmem.c
@@ -1274,7 +1274,7 @@ static int fb_getput_cmap(struct fb_info *info, unsigned int cmd,
 	    put_user(compat_ptr(data), &cmap->transp))
 		return -EFAULT;
 
-	err = do_fb_ioctl(info, cmd, (unsigned long) cmap);
+	err = do_fb_ioctl(info, cmd, (__force unsigned long) cmap);
 
 	if (!err) {
 		if (copy_in_user(&cmap32->start,
@@ -1346,7 +1346,7 @@ static long fb_compat_ioctl(struct file *file, unsigned int cmd,
 	case FBIOPAN_DISPLAY:
 	case FBIOGET_CON2FBMAP:
 	case FBIOPUT_CON2FBMAP:
-		arg = (unsigned long) compat_ptr(arg);
+		arg = (__force unsigned long) compat_ptr(arg);
 		/* fall through */
 	case FBIOBLANK:
 		ret = do_fb_ioctl(info, cmd, arg);
diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 57390c7666e5..fc5f60935f92 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -843,7 +843,7 @@ struct gntdev_copy_batch {
 static int gntdev_get_page(struct gntdev_copy_batch *batch, void __user *virt,
 			   bool writeable, unsigned long *gfn)
 {
-	unsigned long addr = (unsigned long)virt;
+	unsigned long addr = (__force unsigned long)virt;
 	struct page *page;
 	unsigned long xen_pfn;
 	int ret;
@@ -953,7 +953,7 @@ static int gntdev_grant_copy_seg(struct gntdev_copy_batch *batch,
 			op->flags |= GNTCOPY_source_gref;
 		} else {
 			virt = seg->source.virt + copied;
-			off = (unsigned long)virt & ~XEN_PAGE_MASK;
+			off = (__force unsigned long)virt & ~XEN_PAGE_MASK;
 			len = min(len, (size_t)XEN_PAGE_SIZE - off);
 
 			ret = gntdev_get_page(batch, virt, false, &gfn);
@@ -972,7 +972,7 @@ static int gntdev_grant_copy_seg(struct gntdev_copy_batch *batch,
 			op->flags |= GNTCOPY_dest_gref;
 		} else {
 			virt = seg->dest.virt + copied;
-			off = (unsigned long)virt & ~XEN_PAGE_MASK;
+			off = (__force unsigned long)virt & ~XEN_PAGE_MASK;
 			len = min(len, (size_t)XEN_PAGE_SIZE - off);
 
 			ret = gntdev_get_page(batch, virt, true, &gfn);
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 7e6e682104dc..d4b5dab8a80f 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -558,7 +558,7 @@ static long privcmd_ioctl_mmap_batch(
 
 	if (state.global_error) {
 		/* Write back errors in second pass. */
-		state.user_gfn = (xen_pfn_t *)m.arr;
+		state.user_gfn = (xen_pfn_t __user *)m.arr;
 		state.user_err = m.err;
 		ret = traverse_pages_block(m.num, sizeof(xen_pfn_t),
 					   &pagelist, mmap_return_errors, &state);
@@ -596,7 +596,7 @@ static int lock_pages(
 			return -ENOSPC;
 
 		pinned = get_user_pages_fast(
-			(unsigned long) kbufs[i].uptr,
+			(__force unsigned long) kbufs[i].uptr,
 			requested, FOLL_WRITE, pages);
 		if (pinned < 0)
 			return pinned;
diff --git a/fs/aio.c b/fs/aio.c
index b9350f3360c6..bcf431f3e029 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1084,7 +1084,7 @@ static void aio_complete(struct aio_kiocb *iocb, long res, long res2)
 	ev_page = kmap_atomic(ctx->ring_pages[pos / AIO_EVENTS_PER_PAGE]);
 	event = ev_page + pos % AIO_EVENTS_PER_PAGE;
 
-	event->obj = (u64)(unsigned long)iocb->ki_user_iocb;
+	event->obj = (u64)(__force unsigned long)iocb->ki_user_iocb;
 	event->data = iocb->ki_user_data;
 	event->res = res;
 	event->res2 = res2;
diff --git a/fs/autofs/dev-ioctl.c b/fs/autofs/dev-ioctl.c
index 86eafda4a652..f30c7dfec42b 100644
--- a/fs/autofs/dev-ioctl.c
+++ b/fs/autofs/dev-ioctl.c
@@ -709,7 +709,8 @@ static long autofs_dev_ioctl(struct file *file, unsigned int command,
 static long autofs_dev_ioctl_compat(struct file *file, unsigned int command,
 				    unsigned long u)
 {
-	return autofs_dev_ioctl(file, command, (unsigned long) compat_ptr(u));
+	return autofs_dev_ioctl(file, command,
+			(__force unsigned long) compat_ptr(u));
 }
 #else
 #define autofs_dev_ioctl_compat NULL
diff --git a/fs/autofs/root.c b/fs/autofs/root.c
index 782e57b911ab..c8ebdeab6708 100644
--- a/fs/autofs/root.c
+++ b/fs/autofs/root.c
@@ -956,7 +956,7 @@ static long autofs_root_compat_ioctl(struct file *filp,
 		ret = autofs_root_ioctl_unlocked(inode, filp, cmd, arg);
 	else
 		ret = autofs_root_ioctl_unlocked(inode, filp, cmd,
-					      (unsigned long) compat_ptr(arg));
+				      (__force unsigned long) compat_ptr(arg));
 
 	return ret;
 }
diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index efae2fb0930a..0292555d19a4 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -258,18 +258,18 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	NEW_AUX_ENT(AT_GID, from_kgid_munged(cred->user_ns, cred->gid));
 	NEW_AUX_ENT(AT_EGID, from_kgid_munged(cred->user_ns, cred->egid));
 	NEW_AUX_ENT(AT_SECURE, bprm->secureexec);
-	NEW_AUX_ENT(AT_RANDOM, (elf_addr_t)(unsigned long)u_rand_bytes);
+	NEW_AUX_ENT(AT_RANDOM, (elf_addr_t)(__force unsigned long)u_rand_bytes);
 #ifdef ELF_HWCAP2
 	NEW_AUX_ENT(AT_HWCAP2, ELF_HWCAP2);
 #endif
 	NEW_AUX_ENT(AT_EXECFN, bprm->exec);
 	if (k_platform) {
 		NEW_AUX_ENT(AT_PLATFORM,
-			    (elf_addr_t)(unsigned long)u_platform);
+			    (elf_addr_t)(__force unsigned long)u_platform);
 	}
 	if (k_base_platform) {
 		NEW_AUX_ENT(AT_BASE_PLATFORM,
-			    (elf_addr_t)(unsigned long)u_base_platform);
+			    (elf_addr_t)(__force unsigned long)u_base_platform);
 	}
 	if (bprm->interp_flags & BINPRM_FLAGS_EXECFD) {
 		NEW_AUX_ENT(AT_EXECFD, bprm->interp_data);
@@ -285,12 +285,12 @@ create_elf_tables(struct linux_binprm *bprm, struct elfhdr *exec,
 	sp = STACK_ADD(p, ei_index);
 
 	items = (argc + 1) + (envc + 1) + 1;
-	bprm->p = STACK_ROUND(sp, items);
+	bprm->p = STACK_ROUND((__force unsigned long)sp, items);
 
 	/* Point sp at the lowest address on the stack */
 #ifdef CONFIG_STACK_GROWSUP
 	sp = (elf_addr_t __user *)bprm->p - items - ei_index;
-	bprm->exec = (unsigned long)sp; /* XXX: PARISC HACK */
+	bprm->exec = (__force unsigned long)sp; /* XXX: PARISC HACK */
 #else
 	sp = (elf_addr_t __user *)bprm->p;
 #endif
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 63600dc2ac4c..da884159b169 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -5971,6 +5971,6 @@ long btrfs_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		break;
 	}
 
-	return btrfs_ioctl(file, cmd, (unsigned long) compat_ptr(arg));
+	return btrfs_ioctl(file, cmd, (__force unsigned long) compat_ptr(arg));
 }
 #endif
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index a9b00942e87d..675a5e862a68 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -152,7 +152,7 @@ static int do_video_get_event(struct file *file,
 	if (kevent == NULL)
 		return -EFAULT;
 
-	err = do_ioctl(file, cmd, (unsigned long)kevent);
+	err = do_ioctl(file, cmd, (__force unsigned long)kevent);
 	if (!err) {
 		err  = convert_in_user(&kevent->type, &up->type);
 		err |= convert_in_user(&kevent->timestamp, &up->timestamp);
@@ -193,7 +193,7 @@ static int do_video_stillpicture(struct file *file,
 	if (err)
 		return -EFAULT;
 
-	err = do_ioctl(file, cmd, (unsigned long) up_native);
+	err = do_ioctl(file, cmd, (__force unsigned long) up_native);
 
 	return err;
 }
@@ -264,7 +264,7 @@ static int sg_ioctl_trans(struct file *file, unsigned int cmd,
 	if (get_user(interface_id, &sgio32->interface_id))
 		return -EFAULT;
 	if (interface_id != 'S')
-		return do_ioctl(file, cmd, (unsigned long)sgio32);
+		return do_ioctl(file, cmd, (__force unsigned long)sgio32);
 
 	if (get_user(iovec_count, &sgio32->iovec_count))
 		return -EFAULT;
@@ -324,7 +324,7 @@ static int sg_ioctl_trans(struct file *file, unsigned int cmd,
 	if (put_user(compat_ptr(data), &sgio->usr_ptr))
 		return -EFAULT;
 
-	err = do_ioctl(file, cmd, (unsigned long) sgio);
+	err = do_ioctl(file, cmd, (__force unsigned long) sgio);
 
 	if (err >= 0) {
 		void __user *datap;
@@ -332,7 +332,7 @@ static int sg_ioctl_trans(struct file *file, unsigned int cmd,
 		if (copy_in_user(&sgio32->pack_id, &sgio->pack_id,
 				 sizeof(int)) ||
 		    get_user(datap, &sgio->usr_ptr) ||
-		    put_user((u32)(unsigned long)datap,
+		    put_user((u32)(__force unsigned long)datap,
 			     &sgio32->usr_ptr) ||
 		    copy_in_user(&sgio32->status, &sgio->status,
 				 (4 * sizeof(unsigned char)) +
@@ -361,7 +361,7 @@ static int sg_grt_trans(struct file *file,
 	int err, i;
 	sg_req_info_t __user *r;
 	r = compat_alloc_user_space(sizeof(sg_req_info_t)*SG_MAX_QUEUE);
-	err = do_ioctl(file, cmd, (unsigned long)r);
+	err = do_ioctl(file, cmd, (__force unsigned long)r);
 	if (err < 0)
 		return err;
 	for (i = 0; i < SG_MAX_QUEUE; i++) {
@@ -371,7 +371,7 @@ static int sg_grt_trans(struct file *file,
 		if (copy_in_user(o + i, r + i, offsetof(sg_req_info_t, usr_ptr)) ||
 		    get_user(ptr, &r[i].usr_ptr) ||
 		    get_user(d, &r[i].duration) ||
-		    put_user((u32)(unsigned long)(ptr), &o[i].usr_ptr) ||
+		    put_user((u32)(__force unsigned long)(ptr), &o[i].usr_ptr) ||
 		    put_user(d, &o[i].duration))
 			return -EFAULT;
 	}
@@ -410,7 +410,7 @@ static int ppp_sock_fprog_ioctl_trans(struct file *file,
 	else
 		cmd = PPPIOCSACTIVE;
 
-	return do_ioctl(file, cmd, (unsigned long) u_fprog64);
+	return do_ioctl(file, cmd, (__force unsigned long) u_fprog64);
 }
 
 struct ppp_option_data32 {
@@ -435,7 +435,7 @@ static int ppp_gidle(struct file *file, unsigned int cmd,
 
 	idle = compat_alloc_user_space(sizeof(*idle));
 
-	err = do_ioctl(file, PPPIOCGIDLE, (unsigned long) idle);
+	err = do_ioctl(file, PPPIOCGIDLE, (__force unsigned long) idle);
 
 	if (!err) {
 		if (get_user(xmit, &idle->xmit_idle) ||
@@ -467,7 +467,7 @@ static int ppp_scompress(struct file *file, unsigned int cmd,
 			 sizeof(__u32) + sizeof(int)))
 		return -EFAULT;
 
-	return do_ioctl(file, PPPIOCSCOMPRESS, (unsigned long) odata);
+	return do_ioctl(file, PPPIOCSCOMPRESS, (__force unsigned long) odata);
 }
 
 #ifdef CONFIG_BLOCK
@@ -607,7 +607,7 @@ static int serial_struct_ioctl(struct file *file,
 		    put_user(0UL, &ss->iomap_base))
 			return -EFAULT;
         }
-	err = do_ioctl(file, cmd, (unsigned long)ss);
+	err = do_ioctl(file, cmd, (__force unsigned long)ss);
         if (cmd == TIOCGSERIAL && err >= 0) {
 		if (copy_in_user(ss32, ss, offsetof(SS32, iomem_base)) ||
 		    get_user(iomem_base, &ss->iomem_base))
@@ -641,14 +641,16 @@ static int rtc_ioctl(struct file *file,
 	case RTC_EPOCH_READ32:
 		ret = do_ioctl(file, (cmd == RTC_IRQP_READ32) ?
 					RTC_IRQP_READ : RTC_EPOCH_READ,
-					(unsigned long)valp);
+					(__force unsigned long)valp);
 		if (ret)
 			return ret;
 		return convert_in_user(valp, (unsigned int __user *)argp);
 	case RTC_IRQP_SET32:
-		return do_ioctl(file, RTC_IRQP_SET, (unsigned long)argp);
+		return do_ioctl(file, RTC_IRQP_SET,
+					(__force unsigned long)argp);
 	case RTC_EPOCH_SET32:
-		return do_ioctl(file, RTC_EPOCH_SET, (unsigned long)argp);
+		return do_ioctl(file, RTC_EPOCH_SET,
+					(__force unsigned long)argp);
 	}
 
 	return -ENOIOCTLCMD;
@@ -1436,7 +1438,7 @@ COMPAT_SYSCALL_DEFINE3(ioctl, unsigned int, fd, unsigned int, cmd,
 	goto out_fput;
 
  found_handler:
-	arg = (unsigned long)compat_ptr(arg);
+	arg = (__force unsigned long)compat_ptr(arg);
  do_ioctl:
 	error = do_vfs_ioctl(f.file, fd, cmd, arg);
  out_fput:
diff --git a/fs/ext2/ioctl.c b/fs/ext2/ioctl.c
index 0367c0039e68..5cf6e2666107 100644
--- a/fs/ext2/ioctl.c
+++ b/fs/ext2/ioctl.c
@@ -183,6 +183,6 @@ long ext2_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	default:
 		return -ENOIOCTLCMD;
 	}
-	return ext2_ioctl(file, cmd, (unsigned long) compat_ptr(arg));
+	return ext2_ioctl(file, cmd, (__force unsigned long) compat_ptr(arg));
 }
 #endif
diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index a7074115d6f6..02c9ffbbb209 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -1107,6 +1107,6 @@ long ext4_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	default:
 		return -ENOIOCTLCMD;
 	}
-	return ext4_ioctl(file, cmd, (unsigned long) compat_ptr(arg));
+	return ext4_ioctl(file, cmd, (__force unsigned long) compat_ptr(arg));
 }
 #endif
diff --git a/fs/fat/file.c b/fs/fat/file.c
index 4f3d72fb1e60..88f267d5042f 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -176,7 +176,8 @@ static long fat_generic_compat_ioctl(struct file *filp, unsigned int cmd,
 				      unsigned long arg)
 
 {
-	return fat_generic_ioctl(filp, cmd, (unsigned long)compat_ptr(arg));
+	return fat_generic_ioctl(filp, cmd,
+			(__force unsigned long)compat_ptr(arg));
 }
 #endif
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 32d0b883e74f..4c0ccfeb2e24 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1255,7 +1255,7 @@ static inline void fuse_page_descs_length_init(struct fuse_req *req,
 
 static inline unsigned long fuse_get_user_addr(const struct iov_iter *ii)
 {
-	return (unsigned long)ii->iov->iov_base + ii->iov_offset;
+	return (__force unsigned long)ii->iov->iov_base + ii->iov_offset;
 }
 
 static inline size_t fuse_get_frag_size(const struct iov_iter *ii,
diff --git a/fs/namespace.c b/fs/namespace.c
index 51f763fb9430..8307bd0399f3 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2672,7 +2672,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)untagged_addr(data);
+	size = TASK_SIZE - (__force unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
diff --git a/fs/readdir.c b/fs/readdir.c
index d97f548e6323..d5de36c3cc66 100644
--- a/fs/readdir.c
+++ b/fs/readdir.c
@@ -366,8 +366,8 @@ static int compat_fillonedir(struct dir_context *ctx, const char *name,
 	buf->result++;
 	dirent = buf->dirent;
 	if (!access_ok(VERIFY_WRITE, dirent,
-			(unsigned long)(dirent->d_name + namlen + 1) -
-				(unsigned long)dirent))
+			(__force unsigned long)(dirent->d_name + namlen + 1) -
+				(__force unsigned long)dirent))
 		goto efault;
 	if (	__put_user(d_ino, &dirent->d_ino) ||
 		__put_user(offset, &dirent->d_offset) ||
diff --git a/fs/signalfd.c b/fs/signalfd.c
index 4fcd1498acf5..23bc1d4d870a 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -105,7 +105,7 @@ static int signalfd_copyinfo(struct signalfd_siginfo __user *uinfo,
 	case SIL_TIMER:
 		new.ssi_tid = kinfo->si_tid;
 		new.ssi_overrun = kinfo->si_overrun;
-		new.ssi_ptr = (long) kinfo->si_ptr;
+		new.ssi_ptr = (__force long) kinfo->si_ptr;
 		new.ssi_int = kinfo->si_int;
 		break;
 	case SIL_POLL:
@@ -122,13 +122,13 @@ static int signalfd_copyinfo(struct signalfd_siginfo __user *uinfo,
 		 * it as SIL_FAULT.
 		 */
 	case SIL_FAULT:
-		new.ssi_addr = (long) kinfo->si_addr;
+		new.ssi_addr = (__force long) kinfo->si_addr;
 #ifdef __ARCH_SI_TRAPNO
 		new.ssi_trapno = kinfo->si_trapno;
 #endif
 		break;
 	case SIL_FAULT_MCEERR:
-		new.ssi_addr = (long) kinfo->si_addr;
+		new.ssi_addr = (__force long) kinfo->si_addr;
 #ifdef __ARCH_SI_TRAPNO
 		new.ssi_trapno = kinfo->si_trapno;
 #endif
@@ -147,11 +147,11 @@ static int signalfd_copyinfo(struct signalfd_siginfo __user *uinfo,
 		 */
 		new.ssi_pid = kinfo->si_pid;
 		new.ssi_uid = kinfo->si_uid;
-		new.ssi_ptr = (long) kinfo->si_ptr;
+		new.ssi_ptr = (__force long) kinfo->si_ptr;
 		new.ssi_int = kinfo->si_int;
 		break;
 	case SIL_SYS:
-		new.ssi_call_addr = (long) kinfo->si_call_addr;
+		new.ssi_call_addr = (__force long) kinfo->si_call_addr;
 		new.ssi_syscall   = kinfo->si_syscall;
 		new.ssi_arch      = kinfo->si_arch;
 		break;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..0cfd80983fea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1297,7 +1297,7 @@ static inline void clear_page_pfmemalloc(struct page *page)
  */
 extern void pagefault_out_of_memory(void);
 
-#define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
+#define offset_in_page(p)	((__force unsigned long)(p) & ~PAGE_MASK)
 
 /*
  * Flags passed to show_mem() and show_free_areas() to suppress output in
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index b1bd2186e6d2..26d08d4ed59b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -579,8 +579,8 @@ static inline int fault_in_pages_writeable(char __user *uaddr, int size)
 	} while (uaddr <= end);
 
 	/* Check whether the range spilled into the next page. */
-	if (((unsigned long)uaddr & PAGE_MASK) ==
-			((unsigned long)end & PAGE_MASK))
+	if (((__force unsigned long)uaddr & PAGE_MASK) ==
+			((__force unsigned long)end & PAGE_MASK))
 		return __put_user(0, end);
 
 	return 0;
@@ -604,8 +604,8 @@ static inline int fault_in_pages_readable(const char __user *uaddr, int size)
 	} while (uaddr <= end);
 
 	/* Check whether the range spilled into the next page. */
-	if (((unsigned long)uaddr & PAGE_MASK) ==
-			((unsigned long)end & PAGE_MASK)) {
+	if (((__force unsigned long)uaddr & PAGE_MASK) ==
+			((__force unsigned long)end & PAGE_MASK)) {
 		return __get_user(c, end);
 	}
 
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 7ed4713d5337..529f526bca1c 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -93,7 +93,7 @@ struct cmsghdr {
 
 #define CMSG_ALIGN(len) ( ((len)+sizeof(long)-1) & ~(sizeof(long)-1) )
 
-#define CMSG_DATA(cmsg)	((void *)((char *)(cmsg) + sizeof(struct cmsghdr)))
+#define CMSG_DATA(cmsg)	((void *)((char __force *)(cmsg) + sizeof(struct cmsghdr)))
 #define CMSG_SPACE(len) (sizeof(struct cmsghdr) + CMSG_ALIGN(len))
 #define CMSG_LEN(len) (sizeof(struct cmsghdr) + (len))
 
diff --git a/ipc/shm.c b/ipc/shm.c
index b0eb3757ab89..310096ffe8c4 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1392,7 +1392,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg,
 	      ulong *raddr, unsigned long shmlba)
 {
 	struct shmid_kernel *shp;
-	unsigned long addr = (unsigned long)shmaddr;
+	unsigned long addr = (__force unsigned long)shmaddr;
 	unsigned long size;
 	struct file *file, *base;
 	int    err;
@@ -1600,7 +1600,7 @@ long ksys_shmdt(char __user *shmaddr)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
-	unsigned long addr = (unsigned long)shmaddr;
+	unsigned long addr = (__force unsigned long)shmaddr;
 	int retval = -EINVAL;
 #ifdef CONFIG_MMU
 	loff_t size = 0;
diff --git a/kernel/futex.c b/kernel/futex.c
index 11fc3bb456d6..8bb0858c795a 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -499,7 +499,7 @@ static void drop_futex_key_refs(union futex_key *key)
 static int
 get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, int rw)
 {
-	unsigned long address = (unsigned long)uaddr;
+	unsigned long address = (__force unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
 	struct page *page, *tail;
 	struct address_space *mapping;
@@ -727,7 +727,7 @@ static int fault_in_user_writeable(u32 __user *uaddr)
 	int ret;
 
 	down_read(&mm->mmap_sem);
-	ret = fixup_user_fault(current, mm, (unsigned long)uaddr,
+	ret = fixup_user_fault(current, mm, (__force unsigned long)uaddr,
 			       FAULT_FLAG_WRITE, NULL);
 	up_read(&mm->mmap_sem);
 
@@ -3584,7 +3584,7 @@ SYSCALL_DEFINE6(futex, u32 __user *, uaddr, int, op, u32, val,
 	 */
 	if (cmd == FUTEX_REQUEUE || cmd == FUTEX_CMP_REQUEUE ||
 	    cmd == FUTEX_CMP_REQUEUE_PI || cmd == FUTEX_WAKE_OP)
-		val2 = (u32) (unsigned long) utime;
+		val2 = (u32) (__force unsigned long) utime;
 
 	return do_futex(uaddr, op, val, tp, uaddr2, val2, val3);
 }
diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
index 83f830acbb5f..b6052ae7b349 100644
--- a/kernel/futex_compat.c
+++ b/kernel/futex_compat.c
@@ -196,7 +196,7 @@ COMPAT_SYSCALL_DEFINE6(futex, u32 __user *, uaddr, int, op, u32, val,
 	}
 	if (cmd == FUTEX_REQUEUE || cmd == FUTEX_CMP_REQUEUE ||
 	    cmd == FUTEX_CMP_REQUEUE_PI || cmd == FUTEX_WAKE_OP)
-		val2 = (int) (unsigned long) utime;
+		val2 = (int) (__force unsigned long) utime;
 
 	return do_futex(uaddr, op, val, tp, uaddr2, val2, val3);
 }
diff --git a/kernel/power/user.c b/kernel/power/user.c
index 2d8b60a3c86b..10a578efc892 100644
--- a/kernel/power/user.c
+++ b/kernel/power/user.c
@@ -431,7 +431,7 @@ snapshot_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 	case SNAPSHOT_CREATE_IMAGE:
 		return snapshot_ioctl(file, cmd,
-				      (unsigned long) compat_ptr(arg));
+				      (__force unsigned long) compat_ptr(arg));
 
 	case SNAPSHOT_SET_SWAP_AREA: {
 		struct compat_resume_swap_area __user *u_swap_area =
diff --git a/kernel/signal.c b/kernel/signal.c
index 5843c541fda9..2bc6d7fdeaec 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -3494,7 +3494,7 @@ do_sigaltstack (const stack_t *ss, stack_t *oss, unsigned long sp)
 				return -ENOMEM;
 		}
 
-		t->sas_ss_sp = (unsigned long) ss_sp;
+		t->sas_ss_sp = (__force unsigned long) ss_sp;
 		t->sas_ss_size = ss_size;
 		t->sas_ss_flags = ss_flags;
 	}
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 8be175df3075..6b1f373d241d 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -1112,9 +1112,9 @@ unsigned long iov_iter_alignment(const struct iov_iter *i)
 		return size;
 	}
 	iterate_all_kinds(i, size, v,
-		(res |= (unsigned long)v.iov_base | v.iov_len, 0),
+		(res |= (__force unsigned long)v.iov_base | v.iov_len, 0),
 		res |= v.bv_offset | v.bv_len,
-		res |= (unsigned long)v.iov_base | v.iov_len
+		res |= (__force unsigned long)v.iov_base | v.iov_len
 	)
 	return res;
 }
@@ -1131,11 +1131,11 @@ unsigned long iov_iter_gap_alignment(const struct iov_iter *i)
 	}
 
 	iterate_all_kinds(i, size, v,
-		(res |= (!res ? 0 : (unsigned long)v.iov_base) |
+		(res |= (!res ? 0 : (__force unsigned long)v.iov_base) |
 			(size != v.iov_len ? size : 0), 0),
 		(res |= (!res ? 0 : (unsigned long)v.bv_offset) |
 			(size != v.bv_len ? size : 0)),
-		(res |= (!res ? 0 : (unsigned long)v.iov_base) |
+		(res |= (!res ? 0 : (__force unsigned long)v.iov_base) |
 			(size != v.iov_len ? size : 0))
 		);
 	return res;
@@ -1196,7 +1196,7 @@ ssize_t iov_iter_get_pages(struct iov_iter *i,
 	if (unlikely(i->type & ITER_PIPE))
 		return pipe_get_pages(i, pages, maxsize, maxpages, start);
 	iterate_all_kinds(i, maxsize, v, ({
-		unsigned long addr = (unsigned long)v.iov_base;
+		unsigned long addr = (__force unsigned long)v.iov_base;
 		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
 		int n;
 		int res;
@@ -1273,7 +1273,7 @@ ssize_t iov_iter_get_pages_alloc(struct iov_iter *i,
 	if (unlikely(i->type & ITER_PIPE))
 		return pipe_get_pages_alloc(i, pages, maxsize, start);
 	iterate_all_kinds(i, maxsize, v, ({
-		unsigned long addr = (unsigned long)v.iov_base;
+		unsigned long addr = (__force unsigned long)v.iov_base;
 		size_t len = v.iov_len + (*start = addr & (PAGE_SIZE - 1));
 		int n;
 		int res;
@@ -1457,7 +1457,7 @@ int iov_iter_npages(const struct iov_iter *i, int maxpages)
 		if (npages >= maxpages)
 			return maxpages;
 	} else iterate_all_kinds(i, size, v, ({
-		unsigned long p = (unsigned long)v.iov_base;
+		unsigned long p = (__force unsigned long)v.iov_base;
 		npages += DIV_ROUND_UP(p + v.iov_len, PAGE_SIZE)
 			- p / PAGE_SIZE;
 		if (npages >= maxpages)
@@ -1467,7 +1467,7 @@ int iov_iter_npages(const struct iov_iter *i, int maxpages)
 		if (npages >= maxpages)
 			return maxpages;
 	}),({
-		unsigned long p = (unsigned long)v.iov_base;
+		unsigned long p = (__force unsigned long)v.iov_base;
 		npages += DIV_ROUND_UP(p + v.iov_len, PAGE_SIZE)
 			- p / PAGE_SIZE;
 		if (npages >= maxpages)
diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 97467cd2bc59..2dc90838a594 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -109,7 +109,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 	src = untagged_addr(src);
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)src;
+	src_addr = (__force unsigned long)src;
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 8b5f56466e00..10cc31f41064 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -42,7 +42,7 @@ static inline long do_strnlen_user(const char __user *src, unsigned long count,
 	 * Do everything aligned. But that means that we
 	 * need to also expand the maximum..
 	 */
-	align = (sizeof(long) - 1) & (unsigned long)src;
+	align = (sizeof(long) - 1) & (__force unsigned long)src;
 	src -= align;
 	max += align;
 
@@ -111,7 +111,7 @@ long strnlen_user(const char __user *str, long count)
 	str = untagged_addr(str);
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)str;
+	src_addr = (__force unsigned long)str;
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index ec657105edbf..e6a6ad7cc054 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -476,7 +476,7 @@ static noinline void __init copy_user_test(void)
 	pr_info("out-of-bounds in strncpy_from_user()\n");
 	unused = strncpy_from_user(kmem, usermem, size + 1);
 
-	vm_munmap((unsigned long)usermem, PAGE_SIZE);
+	vm_munmap((__force unsigned long)usermem, PAGE_SIZE);
 	kfree(kmem);
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..eb7606ab3620 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4728,7 +4728,7 @@ long copy_huge_page_from_user(struct page *dst_page,
 				unsigned int pages_per_huge_page,
 				bool allow_pagefault)
 {
-	void *src = (void *)usr_src;
+	void *src = (__force void *)usr_src;
 	void *page_kaddr;
 	unsigned long i, rc = 0;
 	unsigned long ret_val = pages_per_huge_page * PAGE_SIZE;
diff --git a/mm/migrate.c b/mm/migrate.c
index d6a2e89b086a..9786b5f827cf 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1582,7 +1582,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			goto out_flush;
 		if (get_user(node, nodes + i))
 			goto out_flush;
-		addr = (unsigned long)p;
+		addr = (__force unsigned long)p;
 
 		err = -ENODEV;
 		if (node < 0 || node >= MAX_NUMNODES)
@@ -1656,7 +1656,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 	down_read(&mm->mmap_sem);
 
 	for (i = 0; i < nr_pages; i++) {
-		unsigned long addr = (unsigned long)(*pages);
+		unsigned long addr = (__force unsigned long)(*pages);
 		struct vm_area_struct *vma;
 		struct page *page;
 		int err = -EFAULT;
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index a447092d4635..4a7a55f4614d 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -175,10 +175,10 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 	for (i = 0; i < riovcnt; i++) {
 		iov_len = rvec[i].iov_len;
 		if (iov_len > 0) {
-			nr_pages_iov = ((unsigned long)rvec[i].iov_base
-					+ iov_len)
-				/ PAGE_SIZE - (unsigned long)rvec[i].iov_base
-				/ PAGE_SIZE + 1;
+			nr_pages_iov = ((__force unsigned long)rvec[i].iov_base
+					+ iov_len) / PAGE_SIZE -
+				(__force unsigned long)rvec[i].iov_base
+					/ PAGE_SIZE + 1;
 			nr_pages = max(nr_pages, nr_pages_iov);
 		}
 	}
@@ -218,8 +218,9 @@ static ssize_t process_vm_rw_core(pid_t pid, struct iov_iter *iter,
 
 	for (i = 0; i < riovcnt && iov_iter_count(iter) && !rc; i++)
 		rc = process_vm_rw_single_vec(
-			(unsigned long)rvec[i].iov_base, rvec[i].iov_len,
-			iter, process_pages, mm, task, vm_write);
+			(__force unsigned long)rvec[i].iov_base,
+			rvec[i].iov_len, iter, process_pages, mm, task,
+			vm_write);
 
 	/* copied = space before - space after */
 	total_len -= iov_iter_count(iter);
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 1eaac01f85de..a07dc6ad085f 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -185,7 +185,7 @@ static int hidp_sock_compat_ioctl(struct socket *sock, unsigned int cmd, unsigne
 				copy_to_user(&uca->name[0], &ca.name[0], 128))
 			return -EFAULT;
 
-		arg = (unsigned long) uca;
+		arg = (__force unsigned long) uca;
 
 		/* Fall through. We don't actually write back any _changes_
 		   to the structure anyway, so there's no need to copy back
diff --git a/net/compat.c b/net/compat.c
index 3b2105f6549d..786c71c44f99 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -103,7 +103,7 @@ int get_compat_msghdr(struct msghdr *kmsg,
 	((ucmlen) >= sizeof(struct compat_cmsghdr) && \
 	 (ucmlen) <= (unsigned long) \
 	 ((mhdr)->msg_controllen - \
-	  ((char *)(ucmsg) - (char *)(mhdr)->msg_control)))
+	  ((char __force *)(ucmsg) - (char __force *)(mhdr)->msg_control)))
 
 static inline struct compat_cmsghdr __user *cmsg_compat_nxthdr(struct msghdr *msg,
 		struct compat_cmsghdr __user *cmsg, int cmsg_len)
@@ -582,7 +582,7 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	case MCAST_JOIN_GROUP:
 	case MCAST_LEAVE_GROUP:
 	{
-		struct compat_group_req __user *gr32 = (void *)optval;
+		struct compat_group_req __user *gr32 = (__force void *)optval;
 		struct group_req __user *kgr =
 			compat_alloc_user_space(sizeof(struct group_req));
 		u32 interface;
@@ -603,7 +603,8 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	case MCAST_BLOCK_SOURCE:
 	case MCAST_UNBLOCK_SOURCE:
 	{
-		struct compat_group_source_req __user *gsr32 = (void *)optval;
+		struct compat_group_source_req __user *gsr32 =
+			(__force void *)optval;
 		struct group_source_req __user *kgsr = compat_alloc_user_space(
 			sizeof(struct group_source_req));
 		u32 interface;
@@ -624,7 +625,8 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	}
 	case MCAST_MSFILTER:
 	{
-		struct compat_group_filter __user *gf32 = (void *)optval;
+		struct compat_group_filter __user *gf32 =
+			(__force void *)optval;
 		struct group_filter __user *kgf;
 		u32 interface, fmode, numsrc;
 
@@ -662,7 +664,7 @@ int compat_mc_getsockopt(struct sock *sock, int level, int optname,
 	char __user *optval, int __user *optlen,
 	int (*getsockopt)(struct sock *, int, int, char __user *, int __user *))
 {
-	struct compat_group_filter __user *gf32 = (void *)optval;
+	struct compat_group_filter __user *gf32 = (__force void *)optval;
 	struct group_filter __user *kgf;
 	int __user	*koptlen;
 	u32 interface, fmode, numsrc;
diff --git a/sound/core/control_compat.c b/sound/core/control_compat.c
index 507fd5210c1c..eae6af108bf2 100644
--- a/sound/core/control_compat.c
+++ b/sound/core/control_compat.c
@@ -418,7 +418,8 @@ static int snd_ctl_elem_add_compat(struct snd_ctl_file *file,
 				   sizeof(data->value.enumerated)))
 			goto error;
 		data->value.enumerated.names_ptr =
-			(uintptr_t)compat_ptr(data->value.enumerated.names_ptr);
+			(__force uintptr_t)compat_ptr(
+					data->value.enumerated.names_ptr);
 		break;
 	default:
 		break;
@@ -465,7 +466,7 @@ static inline long snd_ctl_ioctl_compat(struct file *file, unsigned int cmd, uns
 	case SNDRV_CTL_IOCTL_TLV_READ:
 	case SNDRV_CTL_IOCTL_TLV_WRITE:
 	case SNDRV_CTL_IOCTL_TLV_COMMAND:
-		return snd_ctl_ioctl(file, cmd, (unsigned long)argp);
+		return snd_ctl_ioctl(file, cmd, (__force unsigned long)argp);
 	case SNDRV_CTL_IOCTL_ELEM_LIST32:
 		return snd_ctl_elem_list_compat(ctl->card, argp);
 	case SNDRV_CTL_IOCTL_ELEM_INFO32:
diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
index 66c90f486af9..6bf7fc29d6a0 100644
--- a/sound/core/pcm_native.c
+++ b/sound/core/pcm_native.c
@@ -2888,7 +2888,8 @@ static int snd_pcm_common_ioctl(struct file *file,
 	case SNDRV_PCM_IOCTL_START:
 		return snd_pcm_start_lock_irq(substream);
 	case SNDRV_PCM_IOCTL_LINK:
-		return snd_pcm_link(substream, (int)(unsigned long) arg);
+		return snd_pcm_link(substream,
+				(int)(__force unsigned long) arg);
 	case SNDRV_PCM_IOCTL_UNLINK:
 		return snd_pcm_unlink(substream);
 	case SNDRV_PCM_IOCTL_RESUME:
@@ -2925,7 +2926,7 @@ static int snd_pcm_common_ioctl(struct file *file,
 	case SNDRV_PCM_IOCTL_PAUSE:
 		return snd_pcm_action_lock_irq(&snd_pcm_action_pause,
 					       substream,
-					       (int)(unsigned long)arg);
+					       (int)(__force unsigned long)arg);
 	case SNDRV_PCM_IOCTL_WRITEI_FRAMES:
 	case SNDRV_PCM_IOCTL_READI_FRAMES:
 		return snd_pcm_xferi_frames_ioctl(substream, arg);
diff --git a/sound/core/timer_compat.c b/sound/core/timer_compat.c
index e00f7e399e46..b7bf8a99f883 100644
--- a/sound/core/timer_compat.c
+++ b/sound/core/timer_compat.c
@@ -154,7 +154,8 @@ static long __snd_timer_user_ioctl_compat(struct file *file, unsigned int cmd,
 	case SNDRV_TIMER_IOCTL_PAUSE:
 	case SNDRV_TIMER_IOCTL_PAUSE_OLD:
 	case SNDRV_TIMER_IOCTL_NEXT_DEVICE:
-		return __snd_timer_user_ioctl(file, cmd, (unsigned long)argp);
+		return __snd_timer_user_ioctl(file, cmd,
+				(__force unsigned long)argp);
 	case SNDRV_TIMER_IOCTL_GPARAMS32:
 		return snd_timer_user_gparams_compat(file, argp);
 	case SNDRV_TIMER_IOCTL_INFO32:
-- 
2.19.0.rc0.228.g281dcd1b4d0-goog
