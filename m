From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070125234618.28809.8385.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/8] x86 - Specify amount of kernel memory at boot time
Date: Thu, 25 Jan 2007 23:46:18 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch adds the kernelcore= parameter for x86.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 setup.c |    1 +
 1 files changed, 1 insertion(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-rc4-mm1-003_mark_hugepages_movable/arch/i386/kernel/setup.c linux-2.6.20-rc4-mm1-004_x86_set_kernelcore/arch/i386/kernel/setup.c
--- linux-2.6.20-rc4-mm1-003_mark_hugepages_movable/arch/i386/kernel/setup.c	2007-01-17 17:07:57.000000000 +0000
+++ linux-2.6.20-rc4-mm1-004_x86_set_kernelcore/arch/i386/kernel/setup.c	2007-01-25 17:36:17.000000000 +0000
@@ -196,6 +196,7 @@ static int __init parse_mem(char *arg)
 	return 0;
 }
 early_param("mem", parse_mem);
+early_param("kernelcore", cmdline_parse_kernelcore);
 
 #ifdef CONFIG_PROC_VMCORE
 /* elfcorehdr= specifies the location of elf core header

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
