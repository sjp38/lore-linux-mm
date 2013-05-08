Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 9E9676B00D9
	for <linux-mm@kvack.org>; Wed,  8 May 2013 11:53:31 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id um15so1316154pbc.37
        for <linux-mm@kvack.org>; Wed, 08 May 2013 08:53:30 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v5, part4 01/41] vmlinux.lds: add comments for global variables and clean up useless declarations
Date: Wed,  8 May 2013 23:50:58 +0800
Message-Id: <1368028298-7401-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

This patch documents global variables exported from vmlinux.lds.
1) Add comments about usage guidelines for global variables exported
   from vmlinux.lds.S.
2) Remove unused __initdata_begin[] and __initdata_end[].

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Acked-by: Arnd Bergmann <arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 include/asm-generic/sections.h |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index c1a1216..f1a24b5 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -3,6 +3,26 @@
 
 /* References to section boundaries */
 
+/*
+ * Usage guidelines:
+ * _text, _data: architecture specific, don't use them in arch-independent code
+ * [_stext, _etext]: contains .text.* sections, may also contain .rodata.*
+ *                   and/or .init.* sections
+ * [_sdata, _edata]: contains .data.* sections, may also contain .rodata.*
+ *                   and/or .init.* sections.
+ * [__start_rodata, __end_rodata]: contains .rodata.* sections
+ * [__init_begin, __init_end]: contains .init.* sections, but .init.text.*
+ *                   may be out of this range on some architectures.
+ * [_sinittext, _einittext]: contains .init.text.* sections
+ * [__bss_start, __bss_stop]: contains BSS sections
+ *
+ * Following global variables are optional and may be unavailable on some
+ * architectures and/or kernel configurations.
+ *	_text, _data
+ *	__kprobes_text_start, __kprobes_text_end
+ *	__entry_text_start, __entry_text_end
+ *	__ctors_start, __ctors_end
+ */
 extern char _text[], _stext[], _etext[];
 extern char _data[], _sdata[], _edata[];
 extern char __bss_start[], __bss_stop[];
@@ -12,7 +32,6 @@ extern char _end[];
 extern char __per_cpu_load[], __per_cpu_start[], __per_cpu_end[];
 extern char __kprobes_text_start[], __kprobes_text_end[];
 extern char __entry_text_start[], __entry_text_end[];
-extern char __initdata_begin[], __initdata_end[];
 extern char __start_rodata[], __end_rodata[];
 
 /* Start and end of .ctors section - used for constructor calls. */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
