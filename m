Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 6CB4E6B00DF
	for <linux-mm@kvack.org>; Wed,  8 May 2013 11:53:49 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id y19so1054630dan.28
        for <linux-mm@kvack.org>; Wed, 08 May 2013 08:53:48 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v5, part4 04/41] h8300: normalize global variables exported by vmlinux.lds
Date: Wed,  8 May 2013 23:51:01 +0800
Message-Id: <1368028298-7401-5-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>

Generate mandatory global variables __bss_start/__bss_stop in
file vmlinux.lds.

Also remove one unused declaration of _text.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/h8300/boot/compressed/misc.c |    1 -
 arch/h8300/kernel/vmlinux.lds.S   |    2 ++
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/h8300/boot/compressed/misc.c b/arch/h8300/boot/compressed/misc.c
index 51ab6cb..4a1e3dd 100644
--- a/arch/h8300/boot/compressed/misc.c
+++ b/arch/h8300/boot/compressed/misc.c
@@ -79,7 +79,6 @@ static void error(char *m);
 
 int puts(const char *);
 
-extern int _text;		/* Defined in vmlinux.lds.S */
 extern int _end;
 static unsigned long free_mem_ptr;
 static unsigned long free_mem_end_ptr;
diff --git a/arch/h8300/kernel/vmlinux.lds.S b/arch/h8300/kernel/vmlinux.lds.S
index 03d356d..3253fed 100644
--- a/arch/h8300/kernel/vmlinux.lds.S
+++ b/arch/h8300/kernel/vmlinux.lds.S
@@ -132,10 +132,12 @@ SECTIONS
         {
 	. = ALIGN(0x4) ;
 	__sbss = . ;
+	___bss_start = . ;
 		*(.bss*)
 	. = ALIGN(0x4) ;
 		*(COMMON)
 	. = ALIGN(0x4) ;
+	___bss_stop = . ;
 	__ebss = . ;
 	__end = . ;
 	__ramstart = .;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
