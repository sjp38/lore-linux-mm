Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id F09C06B0038
	for <linux-mm@kvack.org>; Sat, 11 Oct 2014 22:15:13 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id z10so3643006pdj.26
        for <linux-mm@kvack.org>; Sat, 11 Oct 2014 19:15:13 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id er15si7293048pad.86.2014.10.11.19.15.12
        for <linux-mm@kvack.org>;
        Sat, 11 Oct 2014 19:15:12 -0700 (PDT)
Date: Sat, 11 Oct 2014 22:15:10 -0400 (EDT)
Message-Id: <20141011.221510.1574777235900788349.davem@davemloft.net>
Subject: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org


I'm getting tons of the following on sparc64:

[603965.383447] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
[603965.396987] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
[603965.410523] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
[603965.424061] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
[603965.437617] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
[603970.554394] log_unaligned: 333 callbacks suppressed
[603970.564041] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
[603970.577576] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
[603970.591122] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
[603970.604669] Kernel unaligned access at TPC[546b60] free_block+0xa0/0x1a0
[603970.618216] Kernel unaligned access at TPC[546b58] free_block+0x98/0x1a0
[603976.515633] log_unaligned: 31 callbacks suppressed
[603976.525092] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603976.540196] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603976.555308] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603976.570411] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603976.585526] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603982.476424] log_unaligned: 43 callbacks suppressed
[603982.485881] Kernel unaligned access at TPC[549378] kmem_cache_alloc+0xd8/0x1e0
[603982.501590] Kernel unaligned access at TPC[5470a8] kmem_cache_free+0xc8/0x200
[603982.501605] Kernel unaligned access at TPC[549378] kmem_cache_alloc+0xd8/0x1e0
[603982.530382] Kernel unaligned access at TPC[5470a8] kmem_cache_free+0xc8/0x200
[603982.544820] Kernel unaligned access at TPC[549378] kmem_cache_alloc+0xd8/0x1e0
[603987.567130] log_unaligned: 11 callbacks suppressed
[603987.576582] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603987.591696] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603987.606811] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603987.621904] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0
[603987.637017] Kernel unaligned access at TPC[548080] cache_alloc_refill+0x180/0x3a0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
