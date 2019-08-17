Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25E32C3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 07:44:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE0C02086C
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 07:44:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="lqRMJL8p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE0C02086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F6F46B000C; Sat, 17 Aug 2019 03:44:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A6AA6B000D; Sat, 17 Aug 2019 03:44:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46F136B000E; Sat, 17 Aug 2019 03:44:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0066.hostedemail.com [216.40.44.66])
	by kanga.kvack.org (Postfix) with ESMTP id 263F16B000C
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:44:43 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9F031181AC9CB
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 07:44:42 +0000 (UTC)
X-FDA: 75831132804.12.kick86_80584a2053234
X-HE-Tag: kick86_80584a2053234
X-Filterd-Recvd-Size: 8030
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 07:44:41 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 469XJl29Mjz9tyPF;
	Sat, 17 Aug 2019 09:44:39 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=lqRMJL8p; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id dhoYL34YTQ9e; Sat, 17 Aug 2019 09:44:39 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 469XJl0kJ0z9tyP6;
	Sat, 17 Aug 2019 09:44:39 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1566027879; bh=2OB73IPwA1xyGUU/Zm+DsLXHeBY22vrfmhjVU3McqWU=;
	h=From:Subject:To:Cc:Date:From;
	b=lqRMJL8p+XRZKMrCrlL434gYKZ/3O8YnAxg0vZ71PqhYy3hY9CRn42EeE8MlOZqZW
	 CRClxTIJ8ReKVExfpLiVmd3NBsA3fYr/Whbzeo8sRw/DvLSA4n6r0XI0PYOg+Wckse
	 t2YLnHrFHto1Qd0NteOYNeMgll20kbdOhjdmXMUw=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 302F08B793;
	Sat, 17 Aug 2019 09:44:40 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id v7IDuIMBzNPg; Sat, 17 Aug 2019 09:44:40 +0200 (CEST)
Received: from localhost.localdomain (unknown [192.168.232.53])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D5ADE8B790;
	Sat, 17 Aug 2019 09:44:39 +0200 (CEST)
Received: by localhost.localdomain (Postfix, from userid 0)
	id 84C6C1056A3; Sat, 17 Aug 2019 07:44:39 +0000 (UTC)
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH] btrfs: fix allocation of bitmap pages.
To: erhard_f@mailbox.org, Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org
Message-Id: <20190817074439.84C6C1056A3@localhost.localdomain>
Date: Sat, 17 Aug 2019 07:44:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Various notifications of type "BUG kmalloc-4096 () : Redzone
overwritten" have been observed recently in various parts of
the kernel. After some time, it has been made a relation with
the use of BTRFS filesystem.

[   22.809700] BUG kmalloc-4096 (Tainted: G        W        ): Redzone overwritten
[   22.809971] -----------------------------------------------------------------------------

[   22.810286] INFO: 0xbe1a5921-0xfbfc06cd. First byte 0x0 instead of 0xcc
[   22.810866] INFO: Allocated in __load_free_space_cache+0x588/0x780 [btrfs] age=22 cpu=0 pid=224
[   22.811193] 	__slab_alloc.constprop.26+0x44/0x70
[   22.811345] 	kmem_cache_alloc_trace+0xf0/0x2ec
[   22.811588] 	__load_free_space_cache+0x588/0x780 [btrfs]
[   22.811848] 	load_free_space_cache+0xf4/0x1b0 [btrfs]
[   22.812090] 	cache_block_group+0x1d0/0x3d0 [btrfs]
[   22.812321] 	find_free_extent+0x680/0x12a4 [btrfs]
[   22.812549] 	btrfs_reserve_extent+0xec/0x220 [btrfs]
[   22.812785] 	btrfs_alloc_tree_block+0x178/0x5f4 [btrfs]
[   22.813032] 	__btrfs_cow_block+0x150/0x5d4 [btrfs]
[   22.813262] 	btrfs_cow_block+0x194/0x298 [btrfs]
[   22.813484] 	commit_cowonly_roots+0x44/0x294 [btrfs]
[   22.813718] 	btrfs_commit_transaction+0x63c/0xc0c [btrfs]
[   22.813973] 	close_ctree+0xf8/0x2a4 [btrfs]
[   22.814107] 	generic_shutdown_super+0x80/0x110
[   22.814250] 	kill_anon_super+0x18/0x30
[   22.814437] 	btrfs_kill_super+0x18/0x90 [btrfs]
[   22.814590] INFO: Freed in proc_cgroup_show+0xc0/0x248 age=41 cpu=0 pid=83
[   22.814841] 	proc_cgroup_show+0xc0/0x248
[   22.814967] 	proc_single_show+0x54/0x98
[   22.815086] 	seq_read+0x278/0x45c
[   22.815190] 	__vfs_read+0x28/0x17c
[   22.815289] 	vfs_read+0xa8/0x14c
[   22.815381] 	ksys_read+0x50/0x94
[   22.815475] 	ret_from_syscall+0x0/0x38

Commit 69d2480456d1 ("btrfs: use copy_page for copying pages instead
of memcpy") changed the way bitmap blocks are copied. But allthough
bitmaps have the size of a page, they were allocated with kzalloc().

Most of the time, kzalloc() allocates aligned blocks of memory, so
copy_page() can be used. But when some debug options like SLAB_DEBUG
are activated, kzalloc() may return unaligned pointer.

On powerpc, memcpy(), copy_page() and other copying functions use
'dcbz' instruction which provides an entire zeroed cacheline to avoid
memory read when the intention is to overwrite a full line. Functions
like memcpy() are writen to care about partial cachelines at the start
and end of the destination, but copy_page() assumes it gets pages. As
pages are naturally cache aligned, copy_page() doesn't care about
partial lines. This means that when copy_page() is called with a
misaligned pointer, a few leading bytes are zeroed.

To fix it, allocate bitmaps with get_zeroed_page() instead of kzalloc()

Reported-by: Erhard F. <erhard_f@mailbox.org>
Link: https://bugzilla.kernel.org/show_bug.cgi?id=204371
Fixes: 69d2480456d1 ("btrfs: use copy_page for copying pages instead of memcpy")
Cc: stable@vger.kernel.org
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
Tested-by: Erhard F. <erhard_f@mailbox.org>
---
 fs/btrfs/free-space-cache.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/btrfs/free-space-cache.c b/fs/btrfs/free-space-cache.c
index 062be9dde4c6..3229a058e025 100644
--- a/fs/btrfs/free-space-cache.c
+++ b/fs/btrfs/free-space-cache.c
@@ -764,7 +764,7 @@ static int __load_free_space_cache(struct btrfs_root *root, struct inode *inode,
 		} else {
 			ASSERT(num_bitmaps);
 			num_bitmaps--;
-			e->bitmap = kzalloc(PAGE_SIZE, GFP_NOFS);
+			e->bitmap = (void *)get_zeroed_page(GFP_NOFS);
 			if (!e->bitmap) {
 				kmem_cache_free(
 					btrfs_free_space_cachep, e);
@@ -1881,7 +1881,7 @@ static void free_bitmap(struct btrfs_free_space_ctl *ctl,
 			struct btrfs_free_space *bitmap_info)
 {
 	unlink_free_space(ctl, bitmap_info);
-	kfree(bitmap_info->bitmap);
+	free_page((unsigned long)bitmap_info->bitmap);
 	kmem_cache_free(btrfs_free_space_cachep, bitmap_info);
 	ctl->total_bitmaps--;
 	ctl->op->recalc_thresholds(ctl);
@@ -2135,7 +2135,7 @@ static int insert_into_bitmap(struct btrfs_free_space_ctl *ctl,
 		}
 
 		/* allocate the bitmap */
-		info->bitmap = kzalloc(PAGE_SIZE, GFP_NOFS);
+		info->bitmap = (void *)get_zeroed_page(GFP_NOFS);
 		spin_lock(&ctl->tree_lock);
 		if (!info->bitmap) {
 			ret = -ENOMEM;
@@ -2146,7 +2146,7 @@ static int insert_into_bitmap(struct btrfs_free_space_ctl *ctl,
 
 out:
 	if (info) {
-		kfree(info->bitmap);
+		free_page((unsigned long)info->bitmap);
 		kmem_cache_free(btrfs_free_space_cachep, info);
 	}
 
@@ -2802,7 +2802,7 @@ u64 btrfs_alloc_from_cluster(struct btrfs_block_group_cache *block_group,
 	if (entry->bytes == 0) {
 		ctl->free_extents--;
 		if (entry->bitmap) {
-			kfree(entry->bitmap);
+			free_page((unsigned long)entry->bitmap);
 			ctl->total_bitmaps--;
 			ctl->op->recalc_thresholds(ctl);
 		}
@@ -3606,7 +3606,7 @@ int test_add_free_space_entry(struct btrfs_block_group_cache *cache,
 	}
 
 	if (!map) {
-		map = kzalloc(PAGE_SIZE, GFP_NOFS);
+		map = (void *)get_zeroed_page(GFP_NOFS);
 		if (!map) {
 			kmem_cache_free(btrfs_free_space_cachep, info);
 			return -ENOMEM;
@@ -3635,7 +3635,7 @@ int test_add_free_space_entry(struct btrfs_block_group_cache *cache,
 
 	if (info)
 		kmem_cache_free(btrfs_free_space_cachep, info);
-	kfree(map);
+	free_page((unsigned long)map);
 	return 0;
 }
 
-- 
2.17.1


