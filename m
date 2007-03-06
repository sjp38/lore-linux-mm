Date: Tue, 6 Mar 2007 13:53:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [10/16] ia64 support
Message-Id: <20070306135314.9f432250.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Add ia64 support for kernel_core_pages/kernel_core_ratio.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/ia64/kernel/efi.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: devel-tree-2.6.20-mm2/arch/ia64/kernel/efi.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/ia64/kernel/efi.c
+++ devel-tree-2.6.20-mm2/arch/ia64/kernel/efi.c
@@ -424,7 +424,11 @@ efi_init (void)
 			max_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else if (memcmp(cp, "min_addr=", 9) == 0) {
 			min_addr = GRANULEROUNDDOWN(memparse(cp + 9, &cp));
-		} else {
+		} else if (memcmp(cp, "kernel_core_pages=",18) == 0) {
+			cp = parse_kernel_core_pages(cp + 18);
+		} else if (memcmp(cp, "kernel_core_ratio=", 18) == 0) {
+			cp = parse_kernel_core_ratio(cp + 18);
+		} else  {
 			while (*cp != ' ' && *cp)
 				++cp;
 			while (*cp == ' ')

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
