From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070301101002.30048.96041.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
References: <20070301100802.30048.45045.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 6/8] x86_64 - Specify amount of kernel memory at boot time
Date: Thu,  1 Mar 2007 10:10:02 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch adds the kernelcore= parameter for x86_64.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 e820.c |    1 +
 1 files changed, 1 insertion(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.20-mm2-005_ppc64_set_kernelcore/arch/x86_64/kernel/e820.c linux-2.6.20-mm2-006_x8664_set_kernelcore/arch/x86_64/kernel/e820.c
--- linux-2.6.20-mm2-005_ppc64_set_kernelcore/arch/x86_64/kernel/e820.c	2007-02-19 01:19:38.000000000 +0000
+++ linux-2.6.20-mm2-006_x8664_set_kernelcore/arch/x86_64/kernel/e820.c	2007-02-19 09:19:53.000000000 +0000
@@ -617,6 +617,7 @@ static int __init parse_memopt(char *p)
 	return 0;
 } 
 early_param("mem", parse_memopt);
+early_param("kernelcore", cmdline_parse_kernelcore);
 
 static int userdef __initdata;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
