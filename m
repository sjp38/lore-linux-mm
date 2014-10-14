Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4D26B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 20:14:28 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so6711424pab.18
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 17:14:28 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id rj8si11429984pdb.192.2014.10.13.17.14.27
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 17:14:28 -0700 (PDT)
Date: Tue, 14 Oct 2014 09:14:54 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: unaligned accesses in SLAB etc.
Message-ID: <20141014001454.GA12575@js1304-P5Q-DELUXE>
References: <20141012.132012.254712930139255731.davem@davemloft.net>
 <alpine.LRH.2.11.1410132320110.9586@adalberg.ut.ee>
 <20141013235219.GA11191@js1304-P5Q-DELUXE>
 <20141013.200416.641735303627599182.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141013.200416.641735303627599182.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mroos@linux.ee, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

On Mon, Oct 13, 2014 at 08:04:16PM -0400, David Miller wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Tue, 14 Oct 2014 08:52:19 +0900
> 
> > I'd like to know that your another problem is related to commit
> > bf0dea23a9c0 ("mm/slab: use percpu allocator for cpu cache").  So,
> > if the commit is reverted, your another problem is also gone
> > completely?
> 
> The other problem has been present forever.

Okay.
Thanks for notifying me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
