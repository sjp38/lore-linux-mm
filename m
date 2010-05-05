Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 55F6A62008B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 17:03:14 -0400 (EDT)
Received: by yxe32 with SMTP id 32so2423313yxe.11
        for <linux-mm@kvack.org>; Wed, 05 May 2010 14:03:13 -0700 (PDT)
From: Marcelo Roberto Jimenez <mroberto@cpti.cetuc.puc-rio.br>
Subject: [PATCH] MM: Fix NR_SECTION_ROOTS == 0 when using using sparsemem extreme.
Date: Wed,  5 May 2010 18:02:46 -0300
Message-Id: <1273093366-3388-1-git-send-email-mroberto@cpti.cetuc.puc-rio.br>
Sender: owner-linux-mm@kvack.org
To: mroberto@cpti.cetuc.puc-rio.br, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Stephen Rothwell <sfr@canb.auug.org.au>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>, Sergei Shtylyov <sshtylyov@mvista.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Got this while compiling for ARM/SA1100:

mm/sparse.c: In function '__section_nr':
mm/sparse.c:135: warning: 'root' is used uninitialized in this function

This patch follows Russell King's suggestion for a new calculation for
NR_SECTION_ROOTS. Thanks also to Sergei Shtylyov for pointing out the
existence of the macro DIV_ROUND_UP.

Signed-off-by: Marcelo Roberto Jimenez <mroberto@cpti.cetuc.puc-rio.br>
---
 include/linux/mmzone.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cf9e458..e90ad64 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -972,7 +972,7 @@ struct mem_section {
 #endif
 
 #define SECTION_NR_TO_ROOT(sec)	((sec) / SECTIONS_PER_ROOT)
-#define NR_SECTION_ROOTS	(NR_MEM_SECTIONS / SECTIONS_PER_ROOT)
+#define NR_SECTION_ROOTS	DIV_ROUND_UP(NR_MEM_SECTIONS, SECTIONS_PER_ROOT)
 #define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
