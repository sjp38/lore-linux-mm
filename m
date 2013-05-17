Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id B8AD36B006E
	for <linux-mm@kvack.org>; Fri, 17 May 2013 11:47:14 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id xa7so3388641pbc.25
        for <linux-mm@kvack.org>; Fri, 17 May 2013 08:47:14 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v7, part3 16/16] AVR32: fix building warnings caused by redifinitions of HZ
Date: Fri, 17 May 2013 23:45:18 +0800
Message-Id: <1368805518-2634-17-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
References: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Haavard Skinnemoen <hskinnemoen@gmail.com>

As suggested by David Howells <dhowells@redhat.com>, use
asm-generic/param.h and uapi/asm-generic/param.h for AVR32.

It also fixes building warnings caused by redifinitions of HZ:
In file included from /ws/linux/kernel/linux.git/include/uapi/linux/param.h:4,
                 from include/linux/timex.h:63,
                 from include/linux/jiffies.h:8,
                 from include/linux/ktime.h:25,
                 from include/linux/timer.h:5,
                 from include/linux/workqueue.h:8,
                 from include/linux/srcu.h:34,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:777,
                 from include/linux/gfp.h:4,
                 from arch/avr32/mm/init.c:10:
/ws/linux/kernel/linux.git/arch/avr32/include/asm/param.h:6:1: warning: "HZ" redefined
In file included from /ws/linux/kernel/linux.git/arch/avr32/include/asm/param.h:4,
                 from /ws/linux/kernel/linux.git/include/uapi/linux/param.h:4,
                 from include/linux/timex.h:63,
                 from include/linux/jiffies.h:8,
                 from include/linux/ktime.h:25,
                 from include/linux/timer.h:5,
                 from include/linux/workqueue.h:8,
                 from include/linux/srcu.h:34,
                 from include/linux/notifier.h:15,
                 from include/linux/memory_hotplug.h:6,
                 from include/linux/mmzone.h:777,
                 from include/linux/gfp.h:4,
                 from arch/avr32/mm/init.c:10:
/ws/linux/kernel/linux.git/arch/avr32/include/uapi/asm/param.h:6:1: warning: this is the location of the previous definition

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/avr32/include/asm/Kbuild       |  1 +
 arch/avr32/include/asm/param.h      |  9 ---------
 arch/avr32/include/uapi/asm/Kbuild  |  1 +
 arch/avr32/include/uapi/asm/param.h | 18 ------------------
 4 files changed, 2 insertions(+), 27 deletions(-)
 delete mode 100644 arch/avr32/include/asm/param.h
 delete mode 100644 arch/avr32/include/uapi/asm/param.h

diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 4dd4f78..d22af85 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -2,3 +2,4 @@
 generic-y	+= clkdev.h
 generic-y	+= exec.h
 generic-y	+= trace_clock.h
+generic-y	+= param.h
diff --git a/arch/avr32/include/asm/param.h b/arch/avr32/include/asm/param.h
deleted file mode 100644
index 009a167..0000000
--- a/arch/avr32/include/asm/param.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef __ASM_AVR32_PARAM_H
-#define __ASM_AVR32_PARAM_H
-
-#include <uapi/asm/param.h>
-
-# define HZ		CONFIG_HZ
-# define USER_HZ	100		/* User interfaces are in "ticks" */
-# define CLOCKS_PER_SEC	(USER_HZ)	/* frequency at which times() counts */
-#endif /* __ASM_AVR32_PARAM_H */
diff --git a/arch/avr32/include/uapi/asm/Kbuild b/arch/avr32/include/uapi/asm/Kbuild
index df53e7a..3b85ead 100644
--- a/arch/avr32/include/uapi/asm/Kbuild
+++ b/arch/avr32/include/uapi/asm/Kbuild
@@ -33,3 +33,4 @@ header-y += termbits.h
 header-y += termios.h
 header-y += types.h
 header-y += unistd.h
+generic-y += param.h
diff --git a/arch/avr32/include/uapi/asm/param.h b/arch/avr32/include/uapi/asm/param.h
deleted file mode 100644
index d28aa5e..0000000
--- a/arch/avr32/include/uapi/asm/param.h
+++ /dev/null
@@ -1,18 +0,0 @@
-#ifndef _UAPI__ASM_AVR32_PARAM_H
-#define _UAPI__ASM_AVR32_PARAM_H
-
-
-#ifndef HZ
-# define HZ		100
-#endif
-
-/* TODO: Should be configurable */
-#define EXEC_PAGESIZE	4096
-
-#ifndef NOGROUP
-# define NOGROUP	(-1)
-#endif
-
-#define MAXHOSTNAMELEN	64
-
-#endif /* _UAPI__ASM_AVR32_PARAM_H */
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
