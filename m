From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/8] devmem/kmem/kcore fixes, cleanups and hwpoison checks
Date: Wed, 13 Jan 2010 21:53:05 +0800
Message-ID: <20100113135305.013124116@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 075526B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:00:30 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Andrew,

Here are some patches on mem/kmem/kcore.
Most of them have been individually reviewed in LKML.

bug fixes
	[PATCH 1/8] vfs: fix too big f_pos handling
	[PATCH 2/8] devmem: check vmalloc address on kmem read/write
	[PATCH 3/8] devmem: fix kmem write bug on memory holes

simplify vread/vwrite 
	[PATCH 4/8] resources: introduce generic page_is_ram()
	[PATCH 5/8] vmalloc: simplify vread()/vwrite()

check for corrupted page
	[PATCH 6/8] hwpoison: prevent /dev/kmem from accessing hwpoison pages
	[PATCH 7/8] hwpoison: prevent /dev/mem from accessing hwpoison pages
	[PATCH 8/8] hwpoison: prevent /dev/kcore from accessing hwpoison pages

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
