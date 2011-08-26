Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BED936B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 22:55:46 -0400 (EDT)
Subject: [PATCH] treewide: Use __printf not
 __attribute__((format(printf,...)))
From: Joe Perches <joe@perches.com>
In-Reply-To: <20110825180734.9beae279.akpm@linux-foundation.org>
References: 
	 <5a0bef0143ed2b3176917fdc0ddd6a47f4c79391.1314303846.git.joe@perches.com>
	 <20110825165006.af771ef7.akpm@linux-foundation.org>
	 <1314316801.19476.6.camel@Joe-Laptop>
	 <20110825170534.0d425c75.akpm@linux-foundation.org>
	 <1314319088.19476.17.camel@Joe-Laptop>
	 <20110825180734.9beae279.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 25 Aug 2011 19:55:37 -0700
Message-ID: <1314327338.19476.30.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jiri Kosina <trivial@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Standardize the style for compiler based printf format verification.
Standardized the location of __printf too.

Done via script and a little typing.

$ grep -rPl --include=*.[ch] -w "__attribute__" * | \
  grep -vP "^(tools|scripts|include/linux/compiler-gcc.h)" | \
  xargs perl -n -i -e 'local $/; while (<>) { s/\b__attribute__\s*\(\s*\(\s*format\s*\(\s*printf\s*,\s*(.+)\s*,\s*(.+)\s*\)\s*\)\s*\)/__printf($1, $2)/g ; print; }'

Completely untested...

Signed-off-by: Joe Perches <joe@perches.com>

---

On Thu, 2011-08-25 at 18:07 -0700, Andrew Morton wrote:
> On Thu, 25 Aug 2011 17:38:08 -0700 Joe Perches <joe@perches.com> wrote:
> > So if you really like it that much:
> Well I don't particularly like it, personally.  But they're there, so
> we either fully use them or fully unuse them, then remove them.
 
I don't mind one way or another, and I do
like consistency, so I guess the __printf
form is a bit better match to the other
__attribute__ #defines.

I just don't have any particular desire
to push it to anyone though.

Here it is, totally untested.

 arch/alpha/boot/misc.c                       |    3 +-
 arch/alpha/include/asm/console.h             |    3 +-
 arch/frv/include/asm/system.h                |    2 +-
 arch/ia64/include/asm/mca.h                  |    3 +-
 arch/m68k/include/asm/natfeat.h              |    3 +-
 arch/mn10300/include/asm/gdb-stub.h          |    5 +-
 arch/powerpc/boot/ps3.c                      |    3 +-
 arch/powerpc/boot/stdio.h                    |    5 +-
 arch/powerpc/include/asm/udbg.h              |    3 +-
 arch/s390/include/asm/debug.h                |   11 +--
 arch/um/include/shared/user.h                |    8 +-
 drivers/isdn/hisax/callc.c                   |    4 +-
 drivers/isdn/hisax/hisax.h                   |    4 +-
 drivers/isdn/hisax/isdnl1.h                  |    2 +-
 drivers/isdn/hisax/isdnl3.c                  |    2 +-
 drivers/isdn/hisax/st5481_d.c                |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    3 +-
 drivers/net/wireless/ath/ath.h               |    4 +-
 drivers/net/wireless/ath/ath5k/debug.h       |    4 +-
 drivers/net/wireless/ath/ath6kl/debug.h      |    4 +-
 drivers/net/wireless/b43/b43.h               |   12 +--
 drivers/net/wireless/b43legacy/b43legacy.h   |   16 ++--
 drivers/staging/iio/trigger.h                |    3 +-
 fs/ecryptfs/ecryptfs_kernel.h                |    2 +-
 fs/ext2/ext2.h                               |    8 +-
 fs/ext4/ext4.h                               |   44 +++++-----
 fs/fat/fat.h                                 |    9 +-
 fs/gfs2/glock.h                              |    2 +-
 fs/hpfs/hpfs_fn.h                            |    4 +-
 fs/nilfs2/nilfs.h                            |    8 +-
 fs/ntfs/debug.h                              |   15 ++--
 fs/ocfs2/super.h                             |   14 ++--
 fs/partitions/ldm.c                          |   16 ++--
 fs/udf/udfdecl.h                             |    4 +-
 fs/ufs/ufs.h                                 |    9 ++-
 fs/xfs/xfs_message.h                         |   42 +++++-----
 include/asm-generic/bug.h                    |   11 ++-
 include/drm/drmP.h                           |   10 +-
 include/linux/audit.h                        |   11 +--
 include/linux/blktrace_api.h                 |    2 +-
 include/linux/device.h                       |  110 ++++++++++++--------------
 include/linux/dynamic_debug.h                |   19 ++---
 include/linux/ext3_fs.h                      |   16 ++--
 include/linux/fs.h                           |    4 +-
 include/linux/fscache-cache.h                |    8 +-
 include/linux/gameport.h                     |    8 +-
 include/linux/kallsyms.h                     |    5 +-
 include/linux/kdb.h                          |    9 +--
 include/linux/kernel.h                       |   44 +++++------
 include/linux/kexec.h                        |    4 +-
 include/linux/kmod.h                         |    4 +-
 include/linux/kobject.h                      |   26 +++---
 include/linux/kthread.h                      |    4 +-
 include/linux/libata.h                       |   18 ++--
 include/linux/mm.h                           |    2 +-
 include/linux/mmiotrace.h                    |    8 +--
 include/linux/netdevice.h                    |   34 ++++----
 include/linux/printk.h                       |   12 ++--
 include/linux/quotaops.h                     |    2 +-
 include/linux/seq_file.h                     |    3 +-
 include/linux/trace_seq.h                    |    8 +-
 include/net/bluetooth/bluetooth.h            |    2 +-
 include/net/netfilter/nf_log.h               |    3 +-
 include/net/sock.h                           |    4 +-
 include/sound/core.h                         |    4 +-
 include/sound/info.h                         |    4 +-
 include/sound/seq_kernel.h                   |    4 +-
 include/xen/hvc-console.h                    |    4 +-
 include/xen/xenbus.h                         |   12 ++--
 net/nfc/nfc.h                                |    2 +-
 net/rds/rds.h                                |    8 +-
 net/sunrpc/svc.c                             |    5 +-
 sound/firewire/cmp.c                         |    2 +-
 73 files changed, 343 insertions(+), 381 deletions(-)

diff --git a/arch/alpha/boot/misc.c b/arch/alpha/boot/misc.c
index 3ff9a95..e6ab68c 100644
--- a/arch/alpha/boot/misc.c
+++ b/arch/alpha/boot/misc.c
@@ -25,8 +25,7 @@
 
 #define memzero(s,n)	memset ((s),0,(n))
 #define puts		srm_printk
-extern long srm_printk(const char *, ...)
-     __attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 2) long srm_printk(const char *, ...);
 
 /*
  * gzip delarations
diff --git a/arch/alpha/include/asm/console.h b/arch/alpha/include/asm/console.h
index a3ce4e6..1490c3d 100644
--- a/arch/alpha/include/asm/console.h
+++ b/arch/alpha/include/asm/console.h
@@ -62,8 +62,7 @@ extern long callback_save_env(void);
 extern int srm_fixup(unsigned long new_callback_addr,
 		     unsigned long new_hwrpb_addr);
 extern long srm_puts(const char *, long);
-extern long srm_printk(const char *, ...)
-	__attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 2) long srm_printk(const char *, ...);
 
 struct crb_struct;
 struct hwrpb_struct;
diff --git a/arch/frv/include/asm/system.h b/arch/frv/include/asm/system.h
index 6c10fd2..eb8adb6 100644
--- a/arch/frv/include/asm/system.h
+++ b/arch/frv/include/asm/system.h
@@ -52,7 +52,7 @@ do {									\
 #define set_mb(var, value) \
 	do { var = (value); barrier(); } while (0)
 
-extern void die_if_kernel(const char *, ...) __attribute__((format(printf, 1, 2)));
+extern  __printf(1, 2) void die_if_kernel(const char *, ...);
 extern void free_initmem(void);
 
 #define arch_align_stack(x) (x)
diff --git a/arch/ia64/include/asm/mca.h b/arch/ia64/include/asm/mca.h
index 43f96ab..f10fce3 100644
--- a/arch/ia64/include/asm/mca.h
+++ b/arch/ia64/include/asm/mca.h
@@ -158,8 +158,7 @@ extern int  ia64_reg_MCA_extension(int (*fn)(void *, struct ia64_sal_os_state *)
 extern void ia64_unreg_MCA_extension(void);
 extern unsigned long ia64_get_rnat(unsigned long *);
 extern void ia64_set_psr_mc(void);
-extern void ia64_mca_printk(const char * fmt, ...)
-	 __attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 2) void ia64_mca_printk(const char *fmt, ...);
 
 struct ia64_mca_notify_die {
 	struct ia64_sal_os_state *sos;
diff --git a/arch/m68k/include/asm/natfeat.h b/arch/m68k/include/asm/natfeat.h
index a3521b8..e8da158 100644
--- a/arch/m68k/include/asm/natfeat.h
+++ b/arch/m68k/include/asm/natfeat.h
@@ -16,7 +16,6 @@ long nf_call(long id, ...);
 void nf_init(void);
 void nf_shutdown(void);
 
-void nfprint(const char *fmt, ...)
-	__attribute__ ((format (printf, 1, 2)));
+__printf(1, 2) void nfprint(const char *fmt, ...);
 
 # endif /* _NATFEAT_H */
diff --git a/arch/mn10300/include/asm/gdb-stub.h b/arch/mn10300/include/asm/gdb-stub.h
index f5495ad..2549bd5 100644
--- a/arch/mn10300/include/asm/gdb-stub.h
+++ b/arch/mn10300/include/asm/gdb-stub.h
@@ -145,10 +145,9 @@ extern u8	gdbstub_busy;
 extern u8	gdbstub_rx_unget;
 
 #ifdef CONFIG_GDBSTUB_DEBUGGING
-extern void gdbstub_printk(const char *fmt, ...)
-	__attribute__((format(printf, 1, 2)));
+extern __printf(1, 2) void gdbstub_printk(const char *fmt, ...);
 #else
-static inline __attribute__((format(printf, 1, 2)))
+static inline __printf(1, 2)
 void gdbstub_printk(const char *fmt, ...)
 {
 }
diff --git a/arch/powerpc/boot/ps3.c b/arch/powerpc/boot/ps3.c
index 9954d98..7e3f94c 100644
--- a/arch/powerpc/boot/ps3.c
+++ b/arch/powerpc/boot/ps3.c
@@ -36,8 +36,7 @@ extern int lv1_get_repository_node_value(u64 in_1, u64 in_2, u64 in_3,
 #ifdef DEBUG
 #define DBG(fmt...) printf(fmt)
 #else
-static inline int __attribute__ ((format (printf, 1, 2))) DBG(
-	const char *fmt, ...) {return 0;}
+static inline __printf(1, 2) int DBG(const char *fmt, ...) {return 0;}
 #endif
 
 BSS_STACK(4096);
diff --git a/arch/powerpc/boot/stdio.h b/arch/powerpc/boot/stdio.h
index adffc58..756fc04 100644
--- a/arch/powerpc/boot/stdio.h
+++ b/arch/powerpc/boot/stdio.h
@@ -7,12 +7,11 @@
 #define	EINVAL		22	/* Invalid argument */
 #define ENOSPC		28	/* No space left on device */
 
-extern int printf(const char *fmt, ...) __attribute__((format(printf, 1, 2)));
+extern __printf(1, 2) int printf(const char *fmt, ...);
 
 #define fprintf(fmt, args...)	printf(args)
 
-extern int sprintf(char *buf, const char *fmt, ...)
-	__attribute__((format(printf, 2, 3)));
+extern __printf(2, 3) int sprintf(char *buf, const char *fmt, ...);
 
 extern int vsprintf(char *buf, const char *fmt, va_list args);
 
diff --git a/arch/powerpc/include/asm/udbg.h b/arch/powerpc/include/asm/udbg.h
index 93e05d1..139cb09 100644
--- a/arch/powerpc/include/asm/udbg.h
+++ b/arch/powerpc/include/asm/udbg.h
@@ -24,8 +24,7 @@ extern int udbg_write(const char *s, int n);
 extern int udbg_read(char *buf, int buflen);
 
 extern void register_early_udbg_console(void);
-extern void udbg_printf(const char *fmt, ...)
-	__attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 2) void udbg_printf(const char *fmt, ...);
 extern void udbg_progress(char *s, unsigned short hex);
 
 extern void udbg_init_uart(void __iomem *comport, unsigned int speed,
diff --git a/arch/s390/include/asm/debug.h b/arch/s390/include/asm/debug.h
index 18124b7..cea7114 100644
--- a/arch/s390/include/asm/debug.h
+++ b/arch/s390/include/asm/debug.h
@@ -171,10 +171,8 @@ debug_text_event(debug_info_t* id, int level, const char* txt)
  * IMPORTANT: Use "%s" in sprintf format strings with care! Only pointers are
  * stored in the s390dbf. See Documentation/s390/s390dbf.txt for more details!
  */
-extern debug_entry_t *
-debug_sprintf_event(debug_info_t* id,int level,char *string,...)
-	__attribute__ ((format(printf, 3, 4)));
-
+extern __printf(3, 4) debug_entry_t *
+debug_sprintf_event(debug_info_t* id, int level, char *string, ...);
 
 static inline debug_entry_t*
 debug_exception(debug_info_t* id, int level, void* data, int length)
@@ -214,9 +212,8 @@ debug_text_exception(debug_info_t* id, int level, const char* txt)
  * IMPORTANT: Use "%s" in sprintf format strings with care! Only pointers are
  * stored in the s390dbf. See Documentation/s390/s390dbf.txt for more details!
  */
-extern debug_entry_t *
-debug_sprintf_exception(debug_info_t* id,int level,char *string,...)
-	__attribute__ ((format(printf, 3, 4)));
+extern __printf(3, 4) debug_entry_t *
+debug_sprintf_exception(debug_info_t *id, int level, char *string,...);
 
 int debug_register_view(debug_info_t* id, struct debug_view* view);
 int debug_unregister_view(debug_info_t* id, struct debug_view* view);
diff --git a/arch/um/include/shared/user.h b/arch/um/include/shared/user.h
index 293f7c7..e253af9 100644
--- a/arch/um/include/shared/user.h
+++ b/arch/um/include/shared/user.h
@@ -23,14 +23,12 @@
 #include <stddef.h>
 #endif
 
-extern void panic(const char *fmt, ...)
-	__attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 2) void panic(const char *fmt, ...);
 
 #ifdef UML_CONFIG_PRINTK
-extern int printk(const char *fmt, ...)
-	__attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 2) int printk(const char *fmt, ...);
 #else
-static inline int printk(const char *fmt, ...)
+static inline __printf(1, 2) int printk(const char *fmt, ...)
 {
 	return 0;
 }
diff --git a/drivers/isdn/hisax/callc.c b/drivers/isdn/hisax/callc.c
index 37e685e..c4897e1 100644
--- a/drivers/isdn/hisax/callc.c
+++ b/drivers/isdn/hisax/callc.c
@@ -65,7 +65,7 @@ hisax_findcard(int driverid)
 	return (struct IsdnCardState *) 0;
 }
 
-static __attribute__((format(printf, 3, 4))) void
+static __printf(3, 4) void
 link_debug(struct Channel *chanp, int direction, char *fmt, ...)
 {
 	va_list args;
@@ -1068,7 +1068,7 @@ init_d_st(struct Channel *chanp)
 	return 0;
 }
 
-static __attribute__((format(printf, 2, 3))) void
+static __printf(2, 3) void
 callc_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 0a5c42a..aff45a1 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1287,9 +1287,9 @@ int jiftime(char *s, long mark);
 
 int HiSax_command(isdn_ctrl * ic);
 int HiSax_writebuf_skb(int id, int chan, int ack, struct sk_buff *skb);
-__attribute__((format(printf, 3, 4)))
+__printf(3, 4)
 void HiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt, ...);
-__attribute__((format(printf, 3, 0)))
+__printf(3, 0)
 void VHiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt, va_list args);
 void HiSax_reportcard(int cardnr, int sel);
 int QuickHex(char *txt, u_char * p, int cnt);
diff --git a/drivers/isdn/hisax/isdnl1.h b/drivers/isdn/hisax/isdnl1.h
index 425d861..66ddcab 100644
--- a/drivers/isdn/hisax/isdnl1.h
+++ b/drivers/isdn/hisax/isdnl1.h
@@ -21,7 +21,7 @@
 #define B_XMTBUFREADY	1
 #define B_ACKPENDING	2
 
-__attribute__((format(printf, 2, 3)))
+__printf(2, 3)
 void debugl1(struct IsdnCardState *cs, char *fmt, ...);
 void DChannel_proc_xmt(struct IsdnCardState *cs);
 void DChannel_proc_rcv(struct IsdnCardState *cs);
diff --git a/drivers/isdn/hisax/isdnl3.c b/drivers/isdn/hisax/isdnl3.c
index ad291f2..1c24e44 100644
--- a/drivers/isdn/hisax/isdnl3.c
+++ b/drivers/isdn/hisax/isdnl3.c
@@ -66,7 +66,7 @@ static char *strL3Event[] =
 	"EV_TIMEOUT",
 };
 
-static __attribute__((format(printf, 2, 3))) void
+static __printf(2, 3) void
 l3m_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
diff --git a/drivers/isdn/hisax/st5481_d.c b/drivers/isdn/hisax/st5481_d.c
index 4408263..db247b7 100644
--- a/drivers/isdn/hisax/st5481_d.c
+++ b/drivers/isdn/hisax/st5481_d.c
@@ -167,7 +167,7 @@ static struct FsmNode L1FnList[] __initdata =
 	{ST_L1_F8, EV_IND_RSY,           l1_ignore},
 };
 
-static __attribute__((format(printf, 2, 3)))
+static __printf(2, 3)
 void l1m_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
@@ -270,7 +270,7 @@ static char *strDoutEvent[] =
 	"EV_DOUT_UNDERRUN",
 };
 
-static __attribute__((format(printf, 2, 3)))
+static __printf(2, 3)
 void dout_debug(struct FsmInst *fi, char *fmt, ...)
 {
 	va_list args;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ed84811..676209b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -579,8 +579,9 @@ extern const struct ethtool_ops mlx4_en_ethtool_ops;
  * printk / logging functions
  */
 
+__printf(3, 4)
 int en_print(const char *level, const struct mlx4_en_priv *priv,
-	     const char *format, ...) __attribute__ ((format (printf, 3, 4)));
+	     const char *format, ...);
 
 #define en_dbg(mlevel, priv, format, arg...)			\
 do {								\
diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index 17c4b56..fc06406 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -178,7 +178,7 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
 void ath_hw_cycle_counters_update(struct ath_common *common);
 int32_t ath_hw_get_listen_time(struct ath_common *common);
 
-extern __attribute__ ((format (printf, 3, 4))) int
+extern __printf(3, 4) int
 ath_printk(const char *level, struct ath_common *common, const char *fmt, ...);
 
 #define ath_emerg(common, fmt, ...)				\
@@ -262,7 +262,7 @@ enum ATH_DEBUG {
 
 #else
 
-static inline  __attribute__ ((format (printf, 3, 4))) int
+static inline  __printf(3, 4) int
 ath_dbg(struct ath_common *common, enum ATH_DEBUG dbg_mask,
 	const char *fmt, ...)
 {
diff --git a/drivers/net/wireless/ath/ath5k/debug.h b/drivers/net/wireless/ath/ath5k/debug.h
index 7f37df3..0a3f916 100644
--- a/drivers/net/wireless/ath/ath5k/debug.h
+++ b/drivers/net/wireless/ath/ath5k/debug.h
@@ -141,10 +141,10 @@ ath5k_debug_printtxbuf(struct ath5k_hw *ah, struct ath5k_buf *bf);
 
 #include <linux/compiler.h>
 
-static inline void __attribute__ ((format (printf, 3, 4)))
+static inline __printf(3, 4) void
 ATH5K_DBG(struct ath5k_hw *ah, unsigned int m, const char *fmt, ...) {}
 
-static inline void __attribute__ ((format (printf, 3, 4)))
+static inline __printf(3, 4) void
 ATH5K_DBG_UNLIMIT(struct ath5k_hw *ah, unsigned int m, const char *fmt, ...)
 {}
 
diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index 66b3999..de9aa99 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -40,8 +40,8 @@ enum ATH6K_DEBUG_MASK {
 };
 
 extern unsigned int debug_mask;
-extern int ath6kl_printk(const char *level, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+int ath6kl_printk(const char *level, const char *fmt, ...);
 
 #define ath6kl_info(fmt, ...)				\
 	ath6kl_printk(KERN_INFO, fmt, ##__VA_ARGS__)
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index f4e9d8b..d211573 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -981,14 +981,10 @@ static inline bool b43_using_pio_transfers(struct b43_wldev *dev)
 #endif
 
 /* Message printing */
-void b43info(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
-void b43err(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
-void b43warn(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
-void b43dbg(struct b43_wl *wl, const char *fmt, ...)
-    __attribute__ ((format(printf, 2, 3)));
+__printf(2, 3) void b43info(struct b43_wl *wl, const char *fmt, ...);
+__printf(2, 3) void b43err(struct b43_wl *wl, const char *fmt, ...);
+__printf(2, 3) void b43warn(struct b43_wl *wl, const char *fmt, ...);
+__printf(2, 3) void b43dbg(struct b43_wl *wl, const char *fmt, ...);
 
 
 /* A WARN_ON variant that vanishes when b43 debugging is disabled.
diff --git a/drivers/net/wireless/b43legacy/b43legacy.h b/drivers/net/wireless/b43legacy/b43legacy.h
index ad4e743..2468716 100644
--- a/drivers/net/wireless/b43legacy/b43legacy.h
+++ b/drivers/net/wireless/b43legacy/b43legacy.h
@@ -814,15 +814,15 @@ struct b43legacy_lopair *b43legacy_get_lopair(struct b43legacy_phy *phy,
 
 
 /* Message printing */
-void b43legacyinfo(struct b43legacy_wl *wl, const char *fmt, ...)
-		__attribute__((format(printf, 2, 3)));
-void b43legacyerr(struct b43legacy_wl *wl, const char *fmt, ...)
-		__attribute__((format(printf, 2, 3)));
-void b43legacywarn(struct b43legacy_wl *wl, const char *fmt, ...)
-		__attribute__((format(printf, 2, 3)));
+__printf(2, 3)
+void b43legacyinfo(struct b43legacy_wl *wl, const char *fmt, ...);
+__printf(2, 3)
+void b43legacyerr(struct b43legacy_wl *wl, const char *fmt, ...);
+__printf(2, 3)
+void b43legacywarn(struct b43legacy_wl *wl, const char *fmt, ...);
 #if B43legacy_DEBUG
-void b43legacydbg(struct b43legacy_wl *wl, const char *fmt, ...)
-		__attribute__((format(printf, 2, 3)));
+__printf(2, 3)
+void b43legacydbg(struct b43legacy_wl *wl, const char *fmt, ...);
 #else /* DEBUG */
 # define b43legacydbg(wl, fmt...) do { /* nothing */ } while (0)
 #endif /* DEBUG */
diff --git a/drivers/staging/iio/trigger.h b/drivers/staging/iio/trigger.h
index 6250434..7a5a283 100644
--- a/drivers/staging/iio/trigger.h
+++ b/drivers/staging/iio/trigger.h
@@ -194,8 +194,7 @@ irqreturn_t iio_pollfunc_store_time(int irq, void *p);
 int iio_triggered_ring_postenable(struct iio_dev *indio_dev);
 int iio_triggered_ring_predisable(struct iio_dev *indio_dev);
 
-struct iio_trigger *iio_allocate_trigger(const char *fmt, ...)
-	__attribute__((format(printf, 1, 2)));
+__printf(1, 2) struct iio_trigger *iio_allocate_trigger(const char *fmt, ...);
 void iio_free_trigger(struct iio_trigger *trig);
 
 #endif /* _IIO_TRIGGER_H_ */
diff --git a/fs/ecryptfs/ecryptfs_kernel.h b/fs/ecryptfs/ecryptfs_kernel.h
index b36c557..54481a3 100644
--- a/fs/ecryptfs/ecryptfs_kernel.h
+++ b/fs/ecryptfs/ecryptfs_kernel.h
@@ -514,7 +514,7 @@ ecryptfs_set_dentry_lower_mnt(struct dentry *dentry, struct vfsmount *lower_mnt)
 
 #define ecryptfs_printk(type, fmt, arg...) \
         __ecryptfs_printk(type "%s: " fmt, __func__, ## arg);
-__attribute__ ((format(printf, 1, 2)))
+__printf(1, 2)
 void __ecryptfs_printk(const char *fmt, ...);
 
 extern const struct file_operations ecryptfs_main_fops;
diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index af9fc89..4f4921c 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -135,10 +135,10 @@ extern long ext2_compat_ioctl(struct file *, unsigned int, unsigned long);
 struct dentry *ext2_get_parent(struct dentry *child);
 
 /* super.c */
-extern void ext2_error (struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern void ext2_msg(struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+void ext2_error (struct super_block *, const char *, const char *, ...);
+extern __printf(3, 4)
+void ext2_msg(struct super_block *, const char *, const char *, ...);
 extern void ext2_update_dynamic_rev (struct super_block *sb);
 extern void ext2_write_super (struct super_block *);
 
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 10fda8e..bc4724b 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1891,40 +1891,40 @@ extern int ext4_group_extend(struct super_block *sb,
 extern void *ext4_kvmalloc(size_t size, gfp_t flags);
 extern void *ext4_kvzalloc(size_t size, gfp_t flags);
 extern void ext4_kvfree(void *ptr);
-extern void __ext4_error(struct super_block *, const char *, unsigned int,
-			 const char *, ...)
-	__attribute__ ((format (printf, 4, 5)));
+extern __printf(4, 5)
+void __ext4_error(struct super_block *, const char *, unsigned int,
+		  const char *, ...);
 #define ext4_error(sb, message...)	__ext4_error(sb, __func__,	\
 						     __LINE__, ## message)
-extern void ext4_error_inode(struct inode *, const char *, unsigned int,
-			     ext4_fsblk_t, const char *, ...)
-	__attribute__ ((format (printf, 5, 6)));
-extern void ext4_error_file(struct file *, const char *, unsigned int,
-			    ext4_fsblk_t, const char *, ...)
-	__attribute__ ((format (printf, 5, 6)));
+extern __printf(5, 6)
+void ext4_error_inode(struct inode *, const char *, unsigned int, ext4_fsblk_t,
+		      const char *, ...);
+extern __printf(5, 6)
+void ext4_error_file(struct file *, const char *, unsigned int, ext4_fsblk_t,
+		     const char *, ...);
 extern void __ext4_std_error(struct super_block *, const char *,
 			     unsigned int, int);
-extern void __ext4_abort(struct super_block *, const char *, unsigned int,
-		       const char *, ...)
-	__attribute__ ((format (printf, 4, 5)));
+extern __printf(4, 5)
+void __ext4_abort(struct super_block *, const char *, unsigned int,
+		  const char *, ...);
 #define ext4_abort(sb, message...)	__ext4_abort(sb, __func__, \
 						       __LINE__, ## message)
-extern void __ext4_warning(struct super_block *, const char *, unsigned int,
-			  const char *, ...)
-	__attribute__ ((format (printf, 4, 5)));
+extern __printf(4, 5)
+void __ext4_warning(struct super_block *, const char *, unsigned int,
+		    const char *, ...);
 #define ext4_warning(sb, message...)	__ext4_warning(sb, __func__, \
 						       __LINE__, ## message)
-extern void ext4_msg(struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+void ext4_msg(struct super_block *, const char *, const char *, ...);
 extern void __dump_mmp_msg(struct super_block *, struct mmp_struct *mmp,
 			   const char *, unsigned int, const char *);
 #define dump_mmp_msg(sb, mmp, msg)	__dump_mmp_msg(sb, mmp, __func__, \
 						       __LINE__, msg)
-extern void __ext4_grp_locked_error(const char *, unsigned int, \
-				    struct super_block *, ext4_group_t, \
-				    unsigned long, ext4_fsblk_t, \
-				    const char *, ...)
-	__attribute__ ((format (printf, 7, 8)));
+extern __printf(7, 8)
+void __ext4_grp_locked_error(const char *, unsigned int,
+			     struct super_block *, ext4_group_t,
+			     unsigned long, ext4_fsblk_t,
+			     const char *, ...);
 #define ext4_grp_locked_error(sb, grp, message...) \
 	__ext4_grp_locked_error(__func__, __LINE__, (sb), (grp), ## message)
 extern void ext4_update_dynamic_rev(struct super_block *sb);
diff --git a/fs/fat/fat.h b/fs/fat/fat.h
index a5d3853..1510a4d 100644
--- a/fs/fat/fat.h
+++ b/fs/fat/fat.h
@@ -326,15 +326,14 @@ extern int fat_fill_super(struct super_block *sb, void *data, int silent,
 extern int fat_flush_inodes(struct super_block *sb, struct inode *i1,
 		            struct inode *i2);
 /* fat/misc.c */
-extern void
-__fat_fs_error(struct super_block *sb, int report, const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4))) __cold;
+extern __printf(3, 4) __cold
+void __fat_fs_error(struct super_block *sb, int report, const char *fmt, ...);
 #define fat_fs_error(sb, fmt, args...)		\
 	__fat_fs_error(sb, 1, fmt , ## args)
 #define fat_fs_error_ratelimit(sb, fmt, args...) \
 	__fat_fs_error(sb, __ratelimit(&MSDOS_SB(sb)->ratelimit), fmt , ## args)
-void fat_msg(struct super_block *sb, const char *level, const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4))) __cold;
+__printf(3, 4) __cold
+void fat_msg(struct super_block *sb, const char *level, const char *fmt, ...);
 extern int fat_clusters_flush(struct super_block *sb);
 extern int fat_chain_add(struct inode *inode, int new_dclus, int nr_cluster);
 extern void fat_time_fat2unix(struct msdos_sb_info *sbi, struct timespec *ts,
diff --git a/fs/gfs2/glock.h b/fs/gfs2/glock.h
index 6670711..2553b85 100644
--- a/fs/gfs2/glock.h
+++ b/fs/gfs2/glock.h
@@ -201,7 +201,7 @@ int gfs2_glock_nq_m(unsigned int num_gh, struct gfs2_holder *ghs);
 void gfs2_glock_dq_m(unsigned int num_gh, struct gfs2_holder *ghs);
 void gfs2_glock_dq_uninit_m(unsigned int num_gh, struct gfs2_holder *ghs);
 
-__attribute__ ((format(printf, 2, 3)))
+__printf(2, 3)
 void gfs2_print_dbg(struct seq_file *seq, const char *fmt, ...);
 
 /**
diff --git a/fs/hpfs/hpfs_fn.h b/fs/hpfs/hpfs_fn.h
index 331b5e2..de94617 100644
--- a/fs/hpfs/hpfs_fn.h
+++ b/fs/hpfs/hpfs_fn.h
@@ -311,8 +311,8 @@ static inline struct hpfs_sb_info *hpfs_sb(struct super_block *sb)
 
 /* super.c */
 
-void hpfs_error(struct super_block *, const char *, ...)
-	__attribute__((format (printf, 2, 3)));
+__printf(2, 3)
+void hpfs_error(struct super_block *, const char *, ...);
 int hpfs_stop_cycles(struct super_block *, int, int *, int *, char *);
 unsigned hpfs_count_one_bitmap(struct super_block *, secno);
 
diff --git a/fs/nilfs2/nilfs.h b/fs/nilfs2/nilfs.h
index 255d5e1..3777d13 100644
--- a/fs/nilfs2/nilfs.h
+++ b/fs/nilfs2/nilfs.h
@@ -276,10 +276,10 @@ int nilfs_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 /* super.c */
 extern struct inode *nilfs_alloc_inode(struct super_block *);
 extern void nilfs_destroy_inode(struct inode *);
-extern void nilfs_error(struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern void nilfs_warning(struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+void nilfs_error(struct super_block *, const char *, const char *, ...);
+extern __printf(3, 4)
+void nilfs_warning(struct super_block *, const char *, const char *, ...);
 extern struct nilfs_super_block *
 nilfs_read_super_block(struct super_block *, u64, int, struct buffer_head **);
 extern int nilfs_store_magic_and_option(struct super_block *,
diff --git a/fs/ntfs/debug.h b/fs/ntfs/debug.h
index 2142b1c..53c27ea 100644
--- a/fs/ntfs/debug.h
+++ b/fs/ntfs/debug.h
@@ -30,8 +30,9 @@
 
 extern int debug_msgs;
 
-extern void __ntfs_debug(const char *file, int line, const char *function,
-	const char *format, ...) __attribute__ ((format (printf, 4, 5)));
+extern __printf(4, 5)
+void __ntfs_debug(const char *file, int line, const char *function,
+		  const char *format, ...);
 /**
  * ntfs_debug - write a debug level message to syslog
  * @f:		a printf format string containing the message
@@ -52,12 +53,14 @@ extern void ntfs_debug_dump_runlist(const runlist_element *rl);
 
 #endif	/* !DEBUG */
 
-extern void __ntfs_warning(const char *function, const struct super_block *sb,
-		const char *fmt, ...) __attribute__ ((format (printf, 3, 4)));
+extern  __printf(3, 4)
+void __ntfs_warning(const char *function, const struct super_block *sb,
+		    const char *fmt, ...);
 #define ntfs_warning(sb, f, a...)	__ntfs_warning(__func__, sb, f, ##a)
 
-extern void __ntfs_error(const char *function, const struct super_block *sb,
-		const char *fmt, ...) __attribute__ ((format (printf, 3, 4)));
+extern  __printf(3, 4)
+void __ntfs_error(const char *function, const struct super_block *sb,
+		  const char *fmt, ...);
 #define ntfs_error(sb, f, a...)		__ntfs_error(__func__, sb, f, ##a)
 
 #endif /* _LINUX_NTFS_DEBUG_H */
diff --git a/fs/ocfs2/super.h b/fs/ocfs2/super.h
index 40c7de0..74ff74c 100644
--- a/fs/ocfs2/super.h
+++ b/fs/ocfs2/super.h
@@ -31,17 +31,15 @@ extern struct workqueue_struct *ocfs2_wq;
 int ocfs2_publish_get_mount_state(struct ocfs2_super *osb,
 				  int node_num);
 
-void __ocfs2_error(struct super_block *sb,
-		   const char *function,
-		   const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
+__printf(3, 4)
+void __ocfs2_error(struct super_block *sb, const char *function,
+		   const char *fmt, ...);
 
 #define ocfs2_error(sb, fmt, args...) __ocfs2_error(sb, __PRETTY_FUNCTION__, fmt, ##args)
 
-void __ocfs2_abort(struct super_block *sb,
-		   const char *function,
-		   const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
+__printf(3, 4)
+void __ocfs2_abort(struct super_block *sb, const char *function,
+		   const char *fmt, ...);
 
 #define ocfs2_abort(sb, fmt, args...) __ocfs2_abort(sb, __PRETTY_FUNCTION__, fmt, ##args)
 
diff --git a/fs/partitions/ldm.c b/fs/partitions/ldm.c
index af9fdf0..8af6723 100644
--- a/fs/partitions/ldm.c
+++ b/fs/partitions/ldm.c
@@ -49,18 +49,20 @@
 #define ldm_error(f, a...) _ldm_printk (KERN_ERR,   __func__, f, ##a)
 #define ldm_info(f, a...)  _ldm_printk (KERN_INFO,  __func__, f, ##a)
 
-__attribute__ ((format (printf, 3, 4)))
-static void _ldm_printk (const char *level, const char *function,
-			 const char *fmt, ...)
+static __printf(3, 4)
+void _ldm_printk(const char *level, const char *function, const char *fmt, ...)
 {
-	static char buf[128];
+	struct va_format vaf;
 	va_list args;
 
 	va_start (args, fmt);
-	vsnprintf (buf, sizeof (buf), fmt, args);
-	va_end (args);
 
-	printk ("%s%s(): %s\n", level, function, buf);
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk("%s%s(): %pV\n", level, function, &vaf);
+
+	va_end (args);
 }
 
 /**
diff --git a/fs/udf/udfdecl.h b/fs/udf/udfdecl.h
index dbd52d4b..4a33c72 100644
--- a/fs/udf/udfdecl.h
+++ b/fs/udf/udfdecl.h
@@ -112,8 +112,8 @@ struct extent_position {
 
 /* super.c */
 
-__attribute__((format(printf, 3, 4)))
-extern void udf_warning(struct super_block *, const char *, const char *, ...);
+extern __printf(3, 4)
+void udf_warning(struct super_block *, const char *, const char *, ...);
 static inline void udf_updated_lvid(struct super_block *sb)
 {
 	struct buffer_head *bh = UDF_SB(sb)->s_lvid_bh;
diff --git a/fs/ufs/ufs.h b/fs/ufs/ufs.h
index 5be2755..19d2d1c 100644
--- a/fs/ufs/ufs.h
+++ b/fs/ufs/ufs.h
@@ -117,9 +117,12 @@ extern int ufs_getfrag_block (struct inode *inode, sector_t fragment, struct buf
 extern const struct file_operations ufs_dir_operations;
 
 /* super.c */
-extern void ufs_warning (struct super_block *, const char *, const char *, ...) __attribute__ ((format (printf, 3, 4)));
-extern void ufs_error (struct super_block *, const char *, const char *, ...) __attribute__ ((format (printf, 3, 4)));
-extern void ufs_panic (struct super_block *, const char *, const char *, ...) __attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+void ufs_warning (struct super_block *, const char *, const char *, ...);
+extern __printf(3, 4)
+void ufs_error (struct super_block *, const char *, const char *, ...);
+extern __printf(3, 4)
+void ufs_panic (struct super_block *, const char *, const char *, ...);
 
 /* symlink.c */
 extern const struct inode_operations ufs_fast_symlink_inode_operations;
diff --git a/fs/xfs/xfs_message.h b/fs/xfs/xfs_message.h
index 7fb7ea0..56dc0c1 100644
--- a/fs/xfs/xfs_message.h
+++ b/fs/xfs/xfs_message.h
@@ -3,31 +3,29 @@
 
 struct xfs_mount;
 
-extern void xfs_emerg(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
-extern void xfs_alert(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
-extern void xfs_alert_tag(const struct xfs_mount *mp, int tag,
-			 const char *fmt, ...)
-        __attribute__ ((format (printf, 3, 4)));
-extern void xfs_crit(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
-extern void xfs_err(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
-extern void xfs_warn(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
-extern void xfs_notice(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
-extern void xfs_info(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+void xfs_emerg(const struct xfs_mount *mp, const char *fmt, ...);
+extern __printf(2, 3)
+void xfs_alert(const struct xfs_mount *mp, const char *fmt, ...);
+extern __printf(3, 4)
+void xfs_alert_tag(const struct xfs_mount *mp, int tag, const char *fmt, ...);
+extern __printf(2, 3)
+void xfs_crit(const struct xfs_mount *mp, const char *fmt, ...);
+extern __printf(2, 3)
+void xfs_err(const struct xfs_mount *mp, const char *fmt, ...);
+extern __printf(2, 3)
+void xfs_warn(const struct xfs_mount *mp, const char *fmt, ...);
+extern __printf(2, 3)
+void xfs_notice(const struct xfs_mount *mp, const char *fmt, ...);
+extern __printf(2, 3)
+void xfs_info(const struct xfs_mount *mp, const char *fmt, ...);
 
 #ifdef DEBUG
-extern void xfs_debug(const struct xfs_mount *mp, const char *fmt, ...)
-        __attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+void xfs_debug(const struct xfs_mount *mp, const char *fmt, ...);
 #else
-static inline void
-__attribute__ ((format (printf, 2, 3)))
-xfs_debug(const struct xfs_mount *mp, const char *fmt, ...)
+static inline __printf(2, 3)
+void xfs_debug(const struct xfs_mount *mp, const char *fmt, ...)
 {
 }
 #endif
diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
index dfb0ec6..84458b0 100644
--- a/include/asm-generic/bug.h
+++ b/include/asm-generic/bug.h
@@ -61,11 +61,12 @@ struct bug_entry {
  */
 #ifndef __WARN_TAINT
 #ifndef __ASSEMBLY__
-extern void warn_slowpath_fmt(const char *file, const int line,
-		const char *fmt, ...) __attribute__((format(printf, 3, 4)));
-extern void warn_slowpath_fmt_taint(const char *file, const int line,
-				    unsigned taint, const char *fmt, ...)
-	__attribute__((format(printf, 4, 5)));
+extern __printf(3, 4)
+void warn_slowpath_fmt(const char *file, const int line,
+		       const char *fmt, ...);
+extern __printf(4, 5)
+void warn_slowpath_fmt_taint(const char *file, const int line, unsigned taint,
+			     const char *fmt, ...);
 extern void warn_slowpath_null(const char *file, const int line);
 #define WANT_WARN_ON_SLOWPATH
 #endif
diff --git a/include/drm/drmP.h b/include/drm/drmP.h
index 7e447f8..36ac9446 100644
--- a/include/drm/drmP.h
+++ b/include/drm/drmP.h
@@ -123,12 +123,12 @@ struct drm_device;
  * using the DRM_DEBUG_KMS and DRM_DEBUG.
  */
 
-extern __attribute__((format (printf, 4, 5)))
+extern __printf(4, 5)
 void drm_ut_debug_printk(unsigned int request_level,
-				const char *prefix,
-				const char *function_name,
-				const char *format, ...);
-extern __attribute__((format (printf, 2, 3)))
+			 const char *prefix,
+			 const char *function_name,
+			 const char *format, ...);
+extern __printf(2, 3)
 int drm_err(const char *func, const char *format, ...);
 
 /***********************************************************************/
diff --git a/include/linux/audit.h b/include/linux/audit.h
index 0c80061..2f81c6f 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -584,14 +584,13 @@ extern int audit_signals;
 #ifdef CONFIG_AUDIT
 /* These are defined in audit.c */
 				/* Public API */
-extern void		    audit_log(struct audit_context *ctx, gfp_t gfp_mask,
-				      int type, const char *fmt, ...)
-				      __attribute__((format(printf,4,5)));
+extern __printf(4, 5)
+void audit_log(struct audit_context *ctx, gfp_t gfp_mask, int type,
+	       const char *fmt, ...);
 
 extern struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask, int type);
-extern void		    audit_log_format(struct audit_buffer *ab,
-					     const char *fmt, ...)
-			    __attribute__((format(printf,2,3)));
+extern __printf(2, 3)
+void audit_log_format(struct audit_buffer *ab, const char *fmt, ...);
 extern void		    audit_log_end(struct audit_buffer *ab);
 extern int		    audit_string_contains_control(const char *string,
 							  size_t len);
diff --git a/include/linux/blktrace_api.h b/include/linux/blktrace_api.h
index 8e9e4bc..4d1a074 100644
--- a/include/linux/blktrace_api.h
+++ b/include/linux/blktrace_api.h
@@ -170,7 +170,7 @@ extern void blk_trace_shutdown(struct request_queue *);
 extern int do_blk_trace_setup(struct request_queue *q, char *name,
 			      dev_t dev, struct block_device *bdev,
 			      struct blk_user_trace_setup *buts);
-extern __attribute__((format(printf, 2, 3)))
+extern __printf(2, 3)
 void __trace_note_message(struct blk_trace *, const char *fmt, ...);
 
 /**
diff --git a/include/linux/device.h b/include/linux/device.h
index 500dad1..ca05ad5 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -615,8 +615,8 @@ static inline const char *dev_name(const struct device *dev)
 	return kobject_name(&dev->kobj);
 }
 
-extern int dev_set_name(struct device *dev, const char *name, ...)
-			__attribute__((format(printf, 2, 3)));
+extern __printf(2, 3)
+int dev_set_name(struct device *dev, const char *name, ...);
 
 #ifdef CONFIG_NUMA
 static inline int dev_to_node(struct device *dev)
@@ -750,10 +750,10 @@ extern struct device *device_create_vargs(struct class *cls,
 					  void *drvdata,
 					  const char *fmt,
 					  va_list vargs);
-extern struct device *device_create(struct class *cls, struct device *parent,
-				    dev_t devt, void *drvdata,
-				    const char *fmt, ...)
-				    __attribute__((format(printf, 5, 6)));
+extern __printf(5, 6)
+struct device *device_create(struct class *cls, struct device *parent,
+			     dev_t devt, void *drvdata,
+			     const char *fmt, ...);
 extern void device_destroy(struct class *cls, dev_t devt);
 
 /*
@@ -797,64 +797,56 @@ extern const char *dev_driver_string(const struct device *dev);
 
 extern int __dev_printk(const char *level, const struct device *dev,
 			struct va_format *vaf);
-extern int dev_printk(const char *level, const struct device *dev,
-		      const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern int dev_emerg(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int dev_alert(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int dev_crit(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int dev_err(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int dev_warn(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int dev_notice(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int _dev_info(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(3, 4)
+int dev_printk(const char *level, const struct device *dev,
+	       const char *fmt, ...)
+	;
+extern __printf(2, 3)
+int dev_emerg(const struct device *dev, const char *fmt, ...);
+extern __printf(2, 3)
+int dev_alert(const struct device *dev, const char *fmt, ...);
+extern __printf(2, 3)
+int dev_crit(const struct device *dev, const char *fmt, ...);
+extern __printf(2, 3)
+int dev_err(const struct device *dev, const char *fmt, ...);
+extern __printf(2, 3)
+int dev_warn(const struct device *dev, const char *fmt, ...);
+extern __printf(2, 3)
+int dev_notice(const struct device *dev, const char *fmt, ...);
+extern __printf(2, 3)
+int _dev_info(const struct device *dev, const char *fmt, ...);
 
 #else
 
 static inline int __dev_printk(const char *level, const struct device *dev,
 			       struct va_format *vaf)
-	 { return 0; }
-static inline int dev_printk(const char *level, const struct device *dev,
-		      const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
-static inline int dev_printk(const char *level, const struct device *dev,
-		      const char *fmt, ...)
-	 { return 0; }
-
-static inline int dev_emerg(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-static inline int dev_emerg(const struct device *dev, const char *fmt, ...)
-	{ return 0; }
-static inline int dev_crit(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-static inline int dev_crit(const struct device *dev, const char *fmt, ...)
-	{ return 0; }
-static inline int dev_alert(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-static inline int dev_alert(const struct device *dev, const char *fmt, ...)
-	{ return 0; }
-static inline int dev_err(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-static inline int dev_err(const struct device *dev, const char *fmt, ...)
-	{ return 0; }
-static inline int dev_warn(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-static inline int dev_warn(const struct device *dev, const char *fmt, ...)
-	{ return 0; }
-static inline int dev_notice(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-static inline int dev_notice(const struct device *dev, const char *fmt, ...)
-	{ return 0; }
-static inline int _dev_info(const struct device *dev, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-static inline int _dev_info(const struct device *dev, const char *fmt, ...)
-	{ return 0; }
+{ return 0; }
+static inline __printf(3, 4)
+int dev_printk(const char *level, const struct device *dev,
+	       const char *fmt, ...)
+{ return 0; }
+
+static inline __printf(2, 3)
+int dev_emerg(const struct device *dev, const char *fmt, ...)
+{ return 0; }
+static inline __printf(2, 3)
+int dev_crit(const struct device *dev, const char *fmt, ...)
+{ return 0; }
+static inline __printf(2, 3)
+int dev_alert(const struct device *dev, const char *fmt, ...)
+{ return 0; }
+static inline __printf(2, 3)
+int dev_err(const struct device *dev, const char *fmt, ...)
+{ return 0; }
+static inline __printf(2, 3)
+int dev_warn(const struct device *dev, const char *fmt, ...)
+{ return 0; }
+static inline __printf(2, 3)
+int dev_notice(const struct device *dev, const char *fmt, ...)
+{ return 0; }
+static inline __printf(2, 3)
+int _dev_info(const struct device *dev, const char *fmt, ...)
+{ return 0; }
 
 #endif
 
diff --git a/include/linux/dynamic_debug.h b/include/linux/dynamic_debug.h
index feaac1e..6738349 100644
--- a/include/linux/dynamic_debug.h
+++ b/include/linux/dynamic_debug.h
@@ -37,22 +37,21 @@ int ddebug_add_module(struct _ddebug *tab, unsigned int n,
 
 #if defined(CONFIG_DYNAMIC_DEBUG)
 extern int ddebug_remove_module(const char *mod_name);
-extern int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+int __dynamic_pr_debug(struct _ddebug *descriptor, const char *fmt, ...);
 
 struct device;
 
-extern int __dynamic_dev_dbg(struct _ddebug *descriptor,
-			     const struct device *dev,
-			     const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+int __dynamic_dev_dbg(struct _ddebug *descriptor, const struct device *dev,
+		      const char *fmt, ...);
 
 struct net_device;
 
-extern int __dynamic_netdev_dbg(struct _ddebug *descriptor,
-			     const struct net_device *dev,
-			     const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+int __dynamic_netdev_dbg(struct _ddebug *descriptor,
+			 const struct net_device *dev,
+			 const char *fmt, ...);
 
 #define dynamic_pr_debug(fmt, ...) do {					\
 	static struct _ddebug descriptor				\
diff --git a/include/linux/ext3_fs.h b/include/linux/ext3_fs.h
index 0244611..8196763 100644
--- a/include/linux/ext3_fs.h
+++ b/include/linux/ext3_fs.h
@@ -937,15 +937,15 @@ extern int ext3_group_extend(struct super_block *sb,
 				ext3_fsblk_t n_blocks_count);
 
 /* super.c */
-extern void ext3_error (struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+void ext3_error (struct super_block *, const char *, const char *, ...);
 extern void __ext3_std_error (struct super_block *, const char *, int);
-extern void ext3_abort (struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern void ext3_warning (struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern void ext3_msg(struct super_block *, const char *, const char *, ...)
-	__attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+void ext3_abort (struct super_block *, const char *, const char *, ...);
+extern __printf(3, 4)
+void ext3_warning (struct super_block *, const char *, const char *, ...);
+extern __printf(3, 4)
+void ext3_msg(struct super_block *, const char *, const char *, ...);
 extern void ext3_update_dynamic_rev (struct super_block *sb);
 
 #define ext3_std_error(sb, errno)				\
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e4fe603..63ca3d3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2622,8 +2622,8 @@ static const struct file_operations __fops = {				\
 	.llseek	 = generic_file_llseek,					\
 };
 
-static inline void __attribute__((format(printf, 1, 2)))
-__simple_attr_check_format(const char *fmt, ...)
+static inline __printf(1, 2)
+void __simple_attr_check_format(const char *fmt, ...)
 {
 	/* don't do anything, just let the compiler check the arguments; */
 }
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index af095b5..ce31408 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -492,10 +492,10 @@ static inline void fscache_end_io(struct fscache_retrieval *op,
 /*
  * out-of-line cache backend functions
  */
-extern void fscache_init_cache(struct fscache_cache *cache,
-			       const struct fscache_cache_ops *ops,
-			       const char *idfmt,
-			       ...) __attribute__ ((format (printf, 3, 4)));
+extern __printf(3, 4)
+void fscache_init_cache(struct fscache_cache *cache,
+			const struct fscache_cache_ops *ops,
+			const char *idfmt, ...);
 
 extern int fscache_add_cache(struct fscache_cache *cache,
 			     struct fscache_object *fsdef,
diff --git a/include/linux/gameport.h b/include/linux/gameport.h
index e74073e..b456b08 100644
--- a/include/linux/gameport.h
+++ b/include/linux/gameport.h
@@ -77,8 +77,8 @@ void __gameport_register_port(struct gameport *gameport, struct module *owner);
 
 void gameport_unregister_port(struct gameport *gameport);
 
-void gameport_set_phys(struct gameport *gameport, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+__printf(2, 3)
+void gameport_set_phys(struct gameport *gameport, const char *fmt, ...);
 
 #else
 
@@ -92,8 +92,8 @@ static inline void gameport_unregister_port(struct gameport *gameport)
 	return;
 }
 
-static inline void gameport_set_phys(struct gameport *gameport,
-				     const char *fmt, ...)
+static inline __printf(2, 3)
+void gameport_set_phys(struct gameport *gameport, const char *fmt, ...)
 {
 	return;
 }
diff --git a/include/linux/kallsyms.h b/include/linux/kallsyms.h
index 0df513b..3875719 100644
--- a/include/linux/kallsyms.h
+++ b/include/linux/kallsyms.h
@@ -101,9 +101,8 @@ static inline int lookup_symbol_attrs(unsigned long addr, unsigned long *size, u
 #endif /*CONFIG_KALLSYMS*/
 
 /* This macro allows us to keep printk typechecking */
-static void __check_printsym_format(const char *fmt, ...)
-__attribute__((format(printf,1,2)));
-static inline void __check_printsym_format(const char *fmt, ...)
+static __printf(1, 2)
+void __check_printsym_format(const char *fmt, ...)
 {
 }
 
diff --git a/include/linux/kdb.h b/include/linux/kdb.h
index 529d9a0..0647258 100644
--- a/include/linux/kdb.h
+++ b/include/linux/kdb.h
@@ -114,12 +114,9 @@ typedef enum {
 } kdb_reason_t;
 
 extern int kdb_trap_printk;
-extern int vkdb_printf(const char *fmt, va_list args)
-	    __attribute__ ((format (printf, 1, 0)));
-extern int kdb_printf(const char *, ...)
-	    __attribute__ ((format (printf, 1, 2)));
-typedef int (*kdb_printf_t)(const char *, ...)
-	     __attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 0) int vkdb_printf(const char *fmt, va_list args);
+extern __printf(1, 2) int kdb_printf(const char *, ...);
+typedef __printf(1, 2) int (*kdb_printf_t)(const char *, ...);
 
 extern void kdb_init(int level);
 
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 46ac9a5..4451697 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -296,20 +296,18 @@ extern long long simple_strtoll(const char *,char **,unsigned int);
 #define strict_strtoull	kstrtoull
 #define strict_strtoll	kstrtoll
 
-extern int sprintf(char * buf, const char * fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int vsprintf(char *buf, const char *, va_list)
-	__attribute__ ((format (printf, 2, 0)));
-extern int snprintf(char * buf, size_t size, const char * fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern int vsnprintf(char *buf, size_t size, const char *fmt, va_list args)
-	__attribute__ ((format (printf, 3, 0)));
-extern int scnprintf(char * buf, size_t size, const char * fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern int vscnprintf(char *buf, size_t size, const char *fmt, va_list args)
-	__attribute__ ((format (printf, 3, 0)));
-extern char *kasprintf(gfp_t gfp, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3) int sprintf(char * buf, const char * fmt, ...);
+extern __printf(2, 0) int vsprintf(char *buf, const char *, va_list);
+extern __printf(3, 4)
+int snprintf(char * buf, size_t size, const char * fmt, ...);
+extern __printf(3, 0)
+int vsnprintf(char *buf, size_t size, const char *fmt, va_list args);
+extern __printf(3, 4)
+int scnprintf(char * buf, size_t size, const char * fmt, ...);
+extern __printf(3, 0)
+int vscnprintf(char *buf, size_t size, const char *fmt, va_list args);
+extern __printf(2, 3)
+char *kasprintf(gfp_t gfp, const char *fmt, ...);
 extern char *kvasprintf(gfp_t gfp, const char *fmt, va_list args);
 
 extern int sscanf(const char *, const char *, ...)
@@ -427,8 +425,8 @@ extern void tracing_start(void);
 extern void tracing_stop(void);
 extern void ftrace_off_permanent(void);
 
-static inline void __attribute__ ((format (printf, 1, 2)))
-____trace_printk_check_format(const char *fmt, ...)
+static inline __printf(1, 2)
+void ____trace_printk_check_format(const char *fmt, ...)
 {
 }
 #define __trace_printk_check_format(fmt, args...)			\
@@ -467,13 +465,11 @@ do {									\
 		__trace_printk(_THIS_IP_, fmt, ##args);		\
 } while (0)
 
-extern int
-__trace_bprintk(unsigned long ip, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+int __trace_bprintk(unsigned long ip, const char *fmt, ...);
 
-extern int
-__trace_printk(unsigned long ip, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+int __trace_printk(unsigned long ip, const char *fmt, ...);
 
 extern void trace_dump_stack(void);
 
@@ -502,8 +498,8 @@ __ftrace_vprintk(unsigned long ip, const char *fmt, va_list ap);
 
 extern void ftrace_dump(enum ftrace_dump_mode oops_dump_mode);
 #else
-static inline int
-trace_printk(const char *fmt, ...) __attribute__ ((format (printf, 1, 2)));
+static inline __printf(1, 2)
+int trace_printk(const char *fmt, ...);
 
 static inline void tracing_start(void) { }
 static inline void tracing_stop(void) { }
diff --git a/include/linux/kexec.h b/include/linux/kexec.h
index 07d9aba..35ca6e3 100644
--- a/include/linux/kexec.h
+++ b/include/linux/kexec.h
@@ -134,8 +134,8 @@ int kexec_should_crash(struct task_struct *);
 void crash_save_cpu(struct pt_regs *regs, int cpu);
 void crash_save_vmcoreinfo(void);
 void arch_crash_save_vmcoreinfo(void);
-void vmcoreinfo_append_str(const char *fmt, ...)
-	__attribute__ ((format (printf, 1, 2)));
+__printf(1, 2)
+void vmcoreinfo_append_str(const char *fmt, ...);
 unsigned long paddr_vmcoreinfo_note(void);
 
 #define VMCOREINFO_OSRELEASE(value) \
diff --git a/include/linux/kmod.h b/include/linux/kmod.h
index 0da38cf..b16f653 100644
--- a/include/linux/kmod.h
+++ b/include/linux/kmod.h
@@ -32,8 +32,8 @@
 extern char modprobe_path[]; /* for sysctl */
 /* modprobe exit status on success, -ve on error.  Return value
  * usually useless though. */
-extern int __request_module(bool wait, const char *name, ...) \
-	__attribute__((format(printf, 2, 3)));
+extern __printf(2, 3)
+int __request_module(bool wait, const char *name, ...);
 #define request_module(mod...) __request_module(true, mod)
 #define request_module_nowait(mod...) __request_module(false, mod)
 #define try_then_request_module(x, mod...) \
diff --git a/include/linux/kobject.h b/include/linux/kobject.h
index 668729c..ad81e1c 100644
--- a/include/linux/kobject.h
+++ b/include/linux/kobject.h
@@ -72,8 +72,8 @@ struct kobject {
 	unsigned int uevent_suppress:1;
 };
 
-extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
-			    __attribute__((format(printf, 2, 3)));
+extern __printf(2, 3)
+int kobject_set_name(struct kobject *kobj, const char *name, ...);
 extern int kobject_set_name_vargs(struct kobject *kobj, const char *fmt,
 				  va_list vargs);
 
@@ -83,15 +83,13 @@ static inline const char *kobject_name(const struct kobject *kobj)
 }
 
 extern void kobject_init(struct kobject *kobj, struct kobj_type *ktype);
-extern int __must_check kobject_add(struct kobject *kobj,
-				    struct kobject *parent,
-				    const char *fmt, ...)
-	__attribute__((format(printf, 3, 4)));
-extern int __must_check kobject_init_and_add(struct kobject *kobj,
-					     struct kobj_type *ktype,
-					     struct kobject *parent,
-					     const char *fmt, ...)
-	__attribute__((format(printf, 4, 5)));
+extern __printf(3, 4) __must_check
+int kobject_add(struct kobject *kobj, struct kobject *parent,
+		const char *fmt, ...);
+extern __printf(4, 5) __must_check
+int kobject_init_and_add(struct kobject *kobj,
+			 struct kobj_type *ktype, struct kobject *parent,
+			 const char *fmt, ...);
 
 extern void kobject_del(struct kobject *kobj);
 
@@ -212,8 +210,8 @@ int kobject_uevent(struct kobject *kobj, enum kobject_action action);
 int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 			char *envp[]);
 
-int add_uevent_var(struct kobj_uevent_env *env, const char *format, ...)
-	__attribute__((format (printf, 2, 3)));
+__printf(2, 3)
+int add_uevent_var(struct kobj_uevent_env *env, const char *format, ...);
 
 int kobject_action_type(const char *buf, size_t count,
 			enum kobject_action *type);
@@ -226,7 +224,7 @@ static inline int kobject_uevent_env(struct kobject *kobj,
 				      char *envp[])
 { return 0; }
 
-static inline __attribute__((format(printf, 2, 3)))
+static inline __printf(2, 3)
 int add_uevent_var(struct kobj_uevent_env *env, const char *format, ...)
 { return 0; }
 
diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 6c1903d..0714b24 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -4,11 +4,11 @@
 #include <linux/err.h>
 #include <linux/sched.h>
 
+__printf(4, 5)
 struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 					   void *data,
 					   int node,
-					   const char namefmt[], ...)
-	__attribute__((format(printf, 4, 5)));
+					   const char namefmt[], ...);
 
 #define kthread_create(threadfn, data, namefmt, arg...) \
 	kthread_create_on_node(threadfn, data, -1, namefmt, ##arg)
diff --git a/include/linux/libata.h b/include/linux/libata.h
index efd6f98..39eb3be 100644
--- a/include/linux/libata.h
+++ b/include/linux/libata.h
@@ -1254,13 +1254,13 @@ static inline int sata_srst_pmp(struct ata_link *link)
 /*
  * printk helpers
  */
-__attribute__((format (printf, 3, 4)))
+__printf(3, 4)
 int ata_port_printk(const struct ata_port *ap, const char *level,
 		    const char *fmt, ...);
-__attribute__((format (printf, 3, 4)))
+__printf(3, 4)
 int ata_link_printk(const struct ata_link *link, const char *level,
 		    const char *fmt, ...);
-__attribute__((format (printf, 3, 4)))
+__printf(3, 4)
 int ata_dev_printk(const struct ata_device *dev, const char *level,
 		   const char *fmt, ...);
 
@@ -1302,10 +1302,10 @@ void ata_print_version(const struct device *dev, const char *version);
 /*
  * ata_eh_info helpers
  */
-extern void __ata_ehi_push_desc(struct ata_eh_info *ehi, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern void ata_ehi_push_desc(struct ata_eh_info *ehi, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+void __ata_ehi_push_desc(struct ata_eh_info *ehi, const char *fmt, ...);
+extern __printf(2, 3)
+void ata_ehi_push_desc(struct ata_eh_info *ehi, const char *fmt, ...);
 extern void ata_ehi_clear_desc(struct ata_eh_info *ehi);
 
 static inline void ata_ehi_hotplugged(struct ata_eh_info *ehi)
@@ -1319,8 +1319,8 @@ static inline void ata_ehi_hotplugged(struct ata_eh_info *ehi)
 /*
  * port description helpers
  */
-extern void ata_port_desc(struct ata_port *ap, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(2, 3)
+void ata_port_desc(struct ata_port *ap, const char *fmt, ...);
 #ifdef CONFIG_PCI
 extern void ata_port_pbar_desc(struct ata_port *ap, int bar, ssize_t offset,
 			       const char *name);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 24b3b0f..3b3e3b8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1334,7 +1334,7 @@ extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
 extern int after_bootmem;
 
-extern __attribute__((format (printf, 3, 4)))
+extern __printf(3, 4)
 void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
diff --git a/include/linux/mmiotrace.h b/include/linux/mmiotrace.h
index 97491f7..c5d5278 100644
--- a/include/linux/mmiotrace.h
+++ b/include/linux/mmiotrace.h
@@ -49,8 +49,7 @@ extern void mmiotrace_ioremap(resource_size_t offset, unsigned long size,
 extern void mmiotrace_iounmap(volatile void __iomem *addr);
 
 /* For anyone to insert markers. Remember trailing newline. */
-extern int mmiotrace_printk(const char *fmt, ...)
-				__attribute__ ((format (printf, 1, 2)));
+extern __printf(1, 2) int mmiotrace_printk(const char *fmt, ...);
 #else /* !CONFIG_MMIOTRACE: */
 static inline int is_kmmio_active(void)
 {
@@ -71,10 +70,7 @@ static inline void mmiotrace_iounmap(volatile void __iomem *addr)
 {
 }
 
-static inline int mmiotrace_printk(const char *fmt, ...)
-				__attribute__ ((format (printf, 1, 0)));
-
-static inline int mmiotrace_printk(const char *fmt, ...)
+static inline __printf(1, 2) int mmiotrace_printk(const char *fmt, ...)
 {
 	return 0;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7207760..31d228f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2618,23 +2618,23 @@ static inline const char *netdev_name(const struct net_device *dev)
 extern int __netdev_printk(const char *level, const struct net_device *dev,
 			struct va_format *vaf);
 
-extern int netdev_printk(const char *level, const struct net_device *dev,
-			 const char *format, ...)
-	__attribute__ ((format (printf, 3, 4)));
-extern int netdev_emerg(const struct net_device *dev, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int netdev_alert(const struct net_device *dev, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int netdev_crit(const struct net_device *dev, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int netdev_err(const struct net_device *dev, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int netdev_warn(const struct net_device *dev, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int netdev_notice(const struct net_device *dev, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int netdev_info(const struct net_device *dev, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
+extern __printf(3, 4)
+int netdev_printk(const char *level, const struct net_device *dev,
+		  const char *format, ...);
+extern __printf(2, 3)
+int netdev_emerg(const struct net_device *dev, const char *format, ...);
+extern __printf(2, 3)
+int netdev_alert(const struct net_device *dev, const char *format, ...);
+extern __printf(2, 3)
+int netdev_crit(const struct net_device *dev, const char *format, ...);
+extern __printf(2, 3)
+int netdev_err(const struct net_device *dev, const char *format, ...);
+extern __printf(2, 3)
+int netdev_warn(const struct net_device *dev, const char *format, ...);
+extern __printf(2, 3)
+int netdev_notice(const struct net_device *dev, const char *format, ...);
+extern __printf(2, 3)
+int netdev_info(const struct net_device *dev, const char *format, ...);
 
 #define MODULE_ALIAS_NETDEV(device) \
 	MODULE_ALIAS("netdev-" device)
diff --git a/include/linux/printk.h b/include/linux/printk.h
index 0101d55..f0e22f7 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -82,22 +82,22 @@ struct va_format {
  * Dummy printk for disabled debugging statements to use whilst maintaining
  * gcc's format and side-effect checking.
  */
-static inline __attribute__ ((format (printf, 1, 2)))
+static inline __printf(1, 2)
 int no_printk(const char *fmt, ...)
 {
 	return 0;
 }
 
-extern asmlinkage __attribute__ ((format (printf, 1, 2)))
+extern asmlinkage __printf(1, 2)
 void early_printk(const char *fmt, ...);
 
 extern int printk_needs_cpu(int cpu);
 extern void printk_tick(void);
 
 #ifdef CONFIG_PRINTK
-asmlinkage __attribute__ ((format (printf, 1, 0)))
+asmlinkage __printf(1, 0)
 int vprintk(const char *fmt, va_list args);
-asmlinkage __attribute__ ((format (printf, 1, 2))) __cold
+asmlinkage __printf(1, 2) __cold
 int printk(const char *fmt, ...);
 
 /*
@@ -117,12 +117,12 @@ extern int kptr_restrict;
 void log_buf_kexec_setup(void);
 void __init setup_log_buf(int early);
 #else
-static inline __attribute__ ((format (printf, 1, 0)))
+static inline __printf(1, 0)
 int vprintk(const char *s, va_list args)
 {
 	return 0;
 }
-static inline __attribute__ ((format (printf, 1, 2))) __cold
+static inline __printf(1, 2) __cold
 int printk(const char *s, ...)
 {
 	return 0;
diff --git a/include/linux/quotaops.h b/include/linux/quotaops.h
index 26f9e36..d93f95e 100644
--- a/include/linux/quotaops.h
+++ b/include/linux/quotaops.h
@@ -31,7 +31,7 @@ static inline bool is_quota_modification(struct inode *inode, struct iattr *ia)
 #define quota_error(sb, fmt, args...) \
 	__quota_error((sb), __func__, fmt , ## args)
 
-extern __attribute__((format (printf, 3, 4)))
+extern __printf(3, 4)
 void __quota_error(struct super_block *sb, const char *func,
 		   const char *fmt, ...);
 
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index be720cd..0b69a46 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -84,8 +84,7 @@ int seq_putc(struct seq_file *m, char c);
 int seq_puts(struct seq_file *m, const char *s);
 int seq_write(struct seq_file *seq, const void *data, size_t len);
 
-int seq_printf(struct seq_file *, const char *, ...)
-	__attribute__ ((format (printf,2,3)));
+__printf(2, 3) int seq_printf(struct seq_file *, const char *, ...);
 
 int seq_path(struct seq_file *, struct path *, char *);
 int seq_dentry(struct seq_file *, struct dentry *, char *);
diff --git a/include/linux/trace_seq.h b/include/linux/trace_seq.h
index 5cf397c..7dadc3d 100644
--- a/include/linux/trace_seq.h
+++ b/include/linux/trace_seq.h
@@ -29,10 +29,10 @@ trace_seq_init(struct trace_seq *s)
  * Currently only defined when tracing is enabled.
  */
 #ifdef CONFIG_TRACING
-extern int trace_seq_printf(struct trace_seq *s, const char *fmt, ...)
-	__attribute__ ((format (printf, 2, 3)));
-extern int trace_seq_vprintf(struct trace_seq *s, const char *fmt, va_list args)
-	__attribute__ ((format (printf, 2, 0)));
+extern __printf(2, 3)
+int trace_seq_printf(struct trace_seq *s, const char *fmt, ...);
+extern __printf(2, 0)
+int trace_seq_vprintf(struct trace_seq *s, const char *fmt, va_list args);
 extern int
 trace_seq_bprintf(struct trace_seq *s, const char *fmt, const u32 *binary);
 extern int trace_print_seq(struct seq_file *m, struct trace_seq *s);
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index e727555..e86af08 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -77,7 +77,7 @@ struct bt_power {
 #define BT_POWER_FORCE_ACTIVE_OFF 0
 #define BT_POWER_FORCE_ACTIVE_ON  1
 
-__attribute__((format (printf, 2, 3)))
+__printf(2, 3)
 int bt_printk(const char *level, const char *fmt, ...);
 
 #define BT_INFO(fmt, arg...)   bt_printk(KERN_INFO, pr_fmt(fmt), ##arg)
diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
index 920997f..e991bd0 100644
--- a/include/net/netfilter/nf_log.h
+++ b/include/net/netfilter/nf_log.h
@@ -53,12 +53,13 @@ int nf_log_bind_pf(u_int8_t pf, const struct nf_logger *logger);
 void nf_log_unbind_pf(u_int8_t pf);
 
 /* Calls the registered backend logging function */
+__printf(7, 8)
 void nf_log_packet(u_int8_t pf,
 		   unsigned int hooknum,
 		   const struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
 		   const struct nf_loginfo *li,
-		   const char *fmt, ...) __attribute__ ((format(printf,7,8)));
+		   const char *fmt, ...);
 
 #endif /* _NF_LOG_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index beb1a91..abb6e0f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -75,8 +75,8 @@
 					printk(KERN_DEBUG msg); } while (0)
 #else
 /* Validate arguments and do nothing */
-static inline void __attribute__ ((format (printf, 2, 3)))
-SOCK_DEBUG(struct sock *sk, const char *msg, ...)
+static inline __printf(2, 3)
+void SOCK_DEBUG(struct sock *sk, const char *msg, ...)
 {
 }
 #endif
diff --git a/include/sound/core.h b/include/sound/core.h
index a91d78e..3be5ab7 100644
--- a/include/sound/core.h
+++ b/include/sound/core.h
@@ -326,9 +326,9 @@ void release_and_free_resource(struct resource *res);
 /* --- */
 
 #if defined(CONFIG_SND_DEBUG) || defined(CONFIG_SND_VERBOSE_PRINTK)
+__printf(4, 5)
 void __snd_printk(unsigned int level, const char *file, int line,
-		  const char *format, ...)
-     __attribute__ ((format (printf, 4, 5)));
+		  const char *format, ...);
 #else
 #define __snd_printk(level, file, line, format, args...) \
 	printk(format, ##args)
diff --git a/include/sound/info.h b/include/sound/info.h
index 4e94cf1..5492cc4 100644
--- a/include/sound/info.h
+++ b/include/sound/info.h
@@ -110,8 +110,8 @@ void snd_card_info_read_oss(struct snd_info_buffer *buffer);
 static inline void snd_card_info_read_oss(struct snd_info_buffer *buffer) {}
 #endif
 
-int snd_iprintf(struct snd_info_buffer *buffer, const char *fmt, ...) \
-				__attribute__ ((format (printf, 2, 3)));
+__printf(2, 3)
+int snd_iprintf(struct snd_info_buffer *buffer, const char *fmt, ...);
 int snd_info_init(void);
 int snd_info_done(void);
 
diff --git a/include/sound/seq_kernel.h b/include/sound/seq_kernel.h
index 3d9afb6..f352a98 100644
--- a/include/sound/seq_kernel.h
+++ b/include/sound/seq_kernel.h
@@ -75,9 +75,9 @@ struct snd_seq_port_callback {
 };
 
 /* interface for kernel client */
+__printf(3, 4)
 int snd_seq_create_kernel_client(struct snd_card *card, int client_index,
-				 const char *name_fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
+				 const char *name_fmt, ...);
 int snd_seq_delete_kernel_client(int client);
 int snd_seq_kernel_client_enqueue(int client, struct snd_seq_event *ev, int atomic, int hop);
 int snd_seq_kernel_client_dispatch(int client, struct snd_seq_event *ev, int atomic, int hop);
diff --git a/include/xen/hvc-console.h b/include/xen/hvc-console.h
index 901724d..b62dfef 100644
--- a/include/xen/hvc-console.h
+++ b/include/xen/hvc-console.h
@@ -6,12 +6,12 @@ extern struct console xenboot_console;
 #ifdef CONFIG_HVC_XEN
 void xen_console_resume(void);
 void xen_raw_console_write(const char *str);
-__attribute__((format(printf, 1, 2)))
+__printf(1, 2)
 void xen_raw_printk(const char *fmt, ...);
 #else
 static inline void xen_console_resume(void) { }
 static inline void xen_raw_console_write(const char *str) { }
-static inline __attribute__((format(printf, 1, 2)))
+static inline __printf(1, 2)
 void xen_raw_printk(const char *fmt, ...) { }
 #endif
 
diff --git a/include/xen/xenbus.h b/include/xen/xenbus.h
index 553a7a2..b1b6676 100644
--- a/include/xen/xenbus.h
+++ b/include/xen/xenbus.h
@@ -157,9 +157,9 @@ int xenbus_scanf(struct xenbus_transaction t,
 	__attribute__((format(scanf, 4, 5)));
 
 /* Single printf and write: returns -errno or 0. */
+__printf(4, 5)
 int xenbus_printf(struct xenbus_transaction t,
-		  const char *dir, const char *node, const char *fmt, ...)
-	__attribute__((format(printf, 4, 5)));
+		  const char *dir, const char *node, const char *fmt, ...);
 
 /* Generic read function: NULL-terminated triples of name,
  * sprintf-style type string, and pointer. Returns 0 or errno.*/
@@ -201,11 +201,11 @@ int xenbus_watch_path(struct xenbus_device *dev, const char *path,
 		      struct xenbus_watch *watch,
 		      void (*callback)(struct xenbus_watch *,
 				       const char **, unsigned int));
+__printf(4, 5)
 int xenbus_watch_pathfmt(struct xenbus_device *dev, struct xenbus_watch *watch,
 			 void (*callback)(struct xenbus_watch *,
 					  const char **, unsigned int),
-			 const char *pathfmt, ...)
-	__attribute__ ((format (printf, 4, 5)));
+			 const char *pathfmt, ...);
 
 int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state new_state);
 int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
@@ -224,9 +224,9 @@ int xenbus_free_evtchn(struct xenbus_device *dev, int port);
 
 enum xenbus_state xenbus_read_driver_state(const char *path);
 
-__attribute__((format(printf, 3, 4)))
+__printf(3, 4)
 void xenbus_dev_error(struct xenbus_device *dev, int err, const char *fmt, ...);
-__attribute__((format(printf, 3, 4)))
+__printf(3, 4)
 void xenbus_dev_fatal(struct xenbus_device *dev, int err, const char *fmt, ...);
 
 const char *xenbus_strstate(enum xenbus_state state);
diff --git a/net/nfc/nfc.h b/net/nfc/nfc.h
index aaf9832..e607500 100644
--- a/net/nfc/nfc.h
+++ b/net/nfc/nfc.h
@@ -27,7 +27,7 @@
 #include <net/nfc.h>
 #include <net/sock.h>
 
-__attribute__((format (printf, 2, 3)))
+__printf(2, 3)
 int nfc_printk(const char *level, const char *fmt, ...);
 
 #define nfc_info(fmt, arg...) nfc_printk(KERN_INFO, fmt, ##arg)
diff --git a/net/rds/rds.h b/net/rds/rds.h
index da8adac..7eaba18 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -36,8 +36,8 @@
 #define rdsdebug(fmt, args...) pr_debug("%s(): " fmt, __func__ , ##args)
 #else
 /* sigh, pr_debug() causes unused variable warnings */
-static inline void __attribute__ ((format (printf, 1, 2)))
-rdsdebug(char *fmt, ...)
+static inline __printf(1, 2)
+void rdsdebug(char *fmt, ...)
 {
 }
 #endif
@@ -625,8 +625,8 @@ void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 			  struct rds_info_lengths *lens,
 			  int (*visitor)(struct rds_connection *, void *),
 			  size_t item_len);
-void __rds_conn_error(struct rds_connection *conn, const char *, ...)
-				__attribute__ ((format (printf, 2, 3)));
+__printf(2, 3)
+void __rds_conn_error(struct rds_connection *conn, const char *, ...);
 #define rds_conn_error(conn, fmt...) \
 	__rds_conn_error(conn, KERN_WARNING "RDS: " fmt)
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6a69a11..447beda 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -956,9 +956,8 @@ static void svc_unregister(const struct svc_serv *serv)
 /*
  * Printk the given error with the address of the client that caused it.
  */
-static int
-__attribute__ ((format (printf, 2, 3)))
-svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
+static __printf(2, 3)
+int svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
 	va_list args;
 	int 	r;
diff --git a/sound/firewire/cmp.c b/sound/firewire/cmp.c
index 14cacbc..76294f2 100644
--- a/sound/firewire/cmp.c
+++ b/sound/firewire/cmp.c
@@ -32,7 +32,7 @@ enum bus_reset_handling {
 	SUCCEED_ON_BUS_RESET,
 };
 
-static __attribute__((format(printf, 2, 3)))
+static __printf(2, 3)
 void cmp_error(struct cmp_connection *c, const char *fmt, ...)
 {
 	va_list va;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
