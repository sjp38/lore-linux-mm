Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 473F36B006E
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 20:04:22 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so6706136pac.28
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 17:04:21 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id cb9si11500478pdb.107.2014.10.13.17.04.20
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 17:04:21 -0700 (PDT)
Date: Mon, 13 Oct 2014 20:04:16 -0400 (EDT)
Message-Id: <20141013.200416.641735303627599182.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141013235219.GA11191@js1304-P5Q-DELUXE>
References: <20141012.132012.254712930139255731.davem@davemloft.net>
	<alpine.LRH.2.11.1410132320110.9586@adalberg.ut.ee>
	<20141013235219.GA11191@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com
Cc: mroos@linux.ee, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Date: Tue, 14 Oct 2014 08:52:19 +0900

> I'd like to know that your another problem is related to commit
> bf0dea23a9c0 ("mm/slab: use percpu allocator for cpu cache").  So,
> if the commit is reverted, your another problem is also gone
> completely?

The other problem has been present forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
