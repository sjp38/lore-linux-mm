Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4BFDD6B004D
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 16:08:23 -0400 (EDT)
Date: Mon, 29 Jun 2009 23:10:14 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090629201014.GA5414@localdomain.by>
References: <20090628173632.GA3890@localdomain.by>
 <84144f020906290243u7a362465p6b1f566257fa3239@mail.gmail.com>
 <20090629101917.GA3093@localdomain.by>
 <1246270774.6364.9.camel@penberg-laptop>
 <1246271880.21450.13.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246271880.21450.13.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.
This is actually draft. We'll discuss details during next merge window (or earlier).

Thanks.
---

hex dump prints not more than HEX_MAX_LINES lines by HEX_ROW_SIZE (16 or 32) bytes.
( min(object->size, HEX_MAX_LINES * HEX_ROW_SIZE) ).

Example (HEX_ROW_SIZE 16):

unreferenced object 0xf68b59b8 (size 32):
  comm "swapper", pid 1, jiffies 4294877610
  hex dump (first 32 bytes):
    70 6e 70 20 30 30 3a 30 31 00 5a 5a 5a 5a 5a 5a  pnp 00:01.ZZZZZZ
    5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a a5  ZZZZZZZZZZZZZZZ.
  backtrace:
    [<c10e931b>] kmemleak_alloc+0x11b/0x2b0
    [<c10e4bc1>] kmem_cache_alloc+0x111/0x1c0
    [<c12c426e>] reserve_range+0x3e/0x1b0
    [<c12c4474>] system_pnp_probe+0x94/0x140
    [<c12bafa4>] pnp_device_probe+0x84/0x100
    [<c12f1939>] driver_probe_device+0x89/0x170
    [<c12f1ab9>] __driver_attach+0x99/0xa0
    [<c12f1048>] bus_for_each_dev+0x58/0x90
    [<c12f1784>] driver_attach+0x24/0x40
    [<c12f0824>] bus_add_driver+0xc4/0x290
    [<c12f1e30>] driver_register+0x70/0x130
    [<c12bacf6>] pnp_register_driver+0x26/0x40
    [<c15d671c>] pnp_system_init+0x1b/0x2e
    [<c100115f>] do_one_initcall+0x3f/0x1a0
    [<c15ac4af>] kernel_init+0x13e/0x1a6
    [<c1003e07>] kernel_thread_helper+0x7/0x10


Example (HEX_ROW_SIZE 32):

unreferenced object 0xf5e2e130 (size 2048):
  comm "modprobe", pid 2084, jiffies 4294880769
  hex dump (first 64 bytes):
    24 97 ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff  $...............................
    fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff fc ff ff ff  ................................
  backtrace:
    [<c10e931b>] kmemleak_alloc+0x11b/0x2b0
    [<c10e587d>] __kmalloc+0x16d/0x210
    [<c10e73cd>] pcpu_mem_alloc+0x2d/0x80
    [<c10e7482>] pcpu_extend_area_map+0x62/0x100
    [<c10e7837>] pcpu_alloc+0x317/0x480
    [<c10e79f7>] __alloc_percpu+0x17/0x30
    [<c122fd54>] alloc_disk_node+0x54/0x150
    [<c122fe6c>] alloc_disk+0x1c/0x40
    [<fd61a25b>] loop_alloc+0x6b/0x170 [loop]
    [<fd61e092>] 0xfd61e092
    [<c100115f>] do_one_initcall+0x3f/0x1a0
    [<c10785ad>] sys_init_module+0xdd/0x220
    [<c100324b>] sysenter_do_call+0x12/0x22
    [<ffffffff>] 0xffffffff
unreferenced object 0xf5d3cd00 (size 32):
  comm "consolechars", pid 2433, jiffies 4294894598
  hex dump (first 32 bytes):
    60 15 58 c1 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a a5  `.X.....ZZZZZZZZZZZZZZZZZZZZZZZ.
  backtrace:
    [<c10e931b>] kmemleak_alloc+0x11b/0x2b0
    [<c10e4bc1>] kmem_cache_alloc+0x111/0x1c0
    [<c12cf49b>] tty_ldisc_try_get+0x2b/0x130
    [<c12cf7d7>] tty_ldisc_get+0x37/0x70
    [<c12cfa54>] tty_ldisc_reinit+0x34/0x70
    [<c12cfac5>] tty_ldisc_release+0x35/0x60
    [<c12ca1fe>] tty_release_dev+0x33e/0x500
    [<c12ca3e0>] tty_release+0x20/0x40
    [<c10ed61d>] __fput+0xed/0x200
    [<c10ed752>] fput+0x22/0x40
    [<c10e96c9>] filp_close+0x49/0x90
    [<c1045445>] put_files_struct+0xb5/0xe0
    [<c10454b5>] exit_files+0x45/0x60
    [<c1046fd3>] do_exit+0x133/0x6c0
    [<c10475a5>] do_group_exit+0x45/0xa0
    [<c1047622>] sys_exit_group+0x22/0x40


hexdump.c can print prefix:
case DUMP_PREFIX_ADDRESS:
    f6998df0: 3c 06 00 00 00 00 00 00 78 69 00 00 ....  <.......xi......................
case DUMP_PREFIX_OFFSET:
    00000000: 3c 06 00 00 00 00 00 00 78 69 00 00 ....  <.......xi......................
default:
    3c 06 00 00 00 00 00 00 78 69 00 00 00 00 00 ....  <.......xi......................

hex_dump_object(struct seq_file *seq, struct kmemleak_object *object)
can be extended to accept prefix flag either. Though I don't think it's so important. So, it prints without any prefix.



diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 5063873..65c5d74 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -160,6 +160,15 @@ struct kmemleak_object {
 /* flag set to not scan the object */
 #define OBJECT_NO_SCAN		(1 << 2)
 
+/* number of bytes to print per line; must be 16 or 32 */
+#define HEX_ROW_SIZE		32
+/* number of bytes to print at a time (1, 2, 4, 8) */
+#define HEX_GROUP_SIZE		1
+/* include ASCII after the hex output */
+#define HEX_ASCII		1
+/* max number of lines to be printed */
+#define HEX_MAX_LINES		2
+
 /* the list of all allocated objects */
 static LIST_HEAD(object_list);
 /* the list of gray-colored objects (see color_gray comment below) */
@@ -181,6 +190,8 @@ static atomic_t kmemleak_initialized = ATOMIC_INIT(0);
 static atomic_t kmemleak_early_log = ATOMIC_INIT(1);
 /* set if a fata kmemleak error has occurred */
 static atomic_t kmemleak_error = ATOMIC_INIT(0);
+/* set if hex dump should be printed */
+static atomic_t kmemleak_hex_dump = ATOMIC_INIT(1);
 
 /* minimum and maximum address that may be valid pointers */
 static unsigned long min_addr = ULONG_MAX;
@@ -258,6 +269,35 @@ static void kmemleak_disable(void);
 	kmemleak_disable();		\
 } while (0)
 
+
+/*
+ * Printing of the objects hex dump to the seq file. The number on lines
+ * to be printed is limited to HEX_MAX_LINES to prevent seq file spamming.
+ * The actual number of printed bytes depends on HEX_ROW_SIZE.
+ * It must be called with the object->lock held.
+ */
+static void hex_dump_object(struct seq_file *seq,
+				struct kmemleak_object *object)
+{
+	const u8 *ptr = (const u8 *)object->pointer;
+	/* Limit the number of lines to HEX_MAX_LINES. */
+	int len = min(object->size, (size_t)(HEX_MAX_LINES * HEX_ROW_SIZE));
+	int i, remaining = len;
+	unsigned char linebuf[200];
+
+	seq_printf(seq, "  hex dump (first %d bytes):\n", len);
+
+	for (i = 0; i < len; i += HEX_ROW_SIZE) {
+		int linelen = min(remaining, HEX_ROW_SIZE);
+		remaining -= HEX_ROW_SIZE;
+		hex_dump_to_buffer(ptr + i, linelen, HEX_ROW_SIZE,
+						   HEX_GROUP_SIZE, linebuf,
+						   sizeof(linebuf), HEX_ASCII);
+
+		seq_printf(seq, "    %s\n", linebuf);
+	}
+}
+
 /*
  * Object colors, encoded with count and min_count:
  * - white - orphan object, not enough references to it (count < min_count)
@@ -303,6 +343,11 @@ static void print_unreferenced(struct seq_file *seq,
 		   object->pointer, object->size);
 	seq_printf(seq, "  comm \"%s\", pid %d, jiffies %lu\n",
 		   object->comm, object->pid, object->jiffies);
+
+	/* check whether hex dump should be printed */
+	if (atomic_read(&kmemleak_hex_dump))
+		hex_dump_object(seq, object);
+
 	seq_printf(seq, "  backtrace:\n");
 
 	for (i = 0; i < object->trace_len; i++) {
@@ -1269,6 +1314,10 @@ static ssize_t kmemleak_write(struct file *file, const char __user *user_buf,
 		start_scan_thread();
 	else if (strncmp(buf, "scan=off", 8) == 0)
 		stop_scan_thread();
+	else if (strncmp(buf, "hexdump=on", 10) == 0)
+		atomic_set(&kmemleak_hex_dump, 1);
+	else if (strncmp(buf, "hexdump=off", 11) == 0)
+		atomic_set(&kmemleak_hex_dump, 0);
 	else if (strncmp(buf, "scan=", 5) == 0) {
 		unsigned long secs;
 		int err;


	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
