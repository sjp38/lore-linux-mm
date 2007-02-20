From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH]: remove __initdata from initkmem_list3
Date: Tue, 20 Feb 2007 11:32:09 -0500
Message-ID: <20070220163209.23777.90564.sendpatchset@prarit.boston.redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030232AbXBTQcS@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Prarit Bhargava <prarit@redhat.com>
List-Id: linux-mm.kvack.org

Remove __initdata from initkmem_list3

Resolves MODPOST warning similar to:

WARNING: vmlinux - Section mismatch: reference to .init.data:initkmem_list3 from .text between 'set_up_list3s' (at offset 0xc046a3ed) and 's_start'

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/mm/slab.c b/mm/slab.c
index 70784b8..d97f252 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -305,7 +305,7 @@ struct kmem_list3 {
  * Need this for bootstrapping a per node allocator.
  */
 #define NUM_INIT_LISTS (2 * MAX_NUMNODES + 1)
-struct kmem_list3 __initdata initkmem_list3[NUM_INIT_LISTS];
+struct kmem_list3 initkmem_list3[NUM_INIT_LISTS];
 #define	CACHE_CACHE 0
 #define	SIZE_AC 1
 #define	SIZE_L3 (1 + MAX_NUMNODES)
