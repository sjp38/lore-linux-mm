Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id DD81C6B006E
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 17:32:50 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lj1so8626967pab.10
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 14:32:50 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id bi14si13850476pdb.245.2014.10.14.14.32.49
        for <linux-mm@kvack.org>;
        Tue, 14 Oct 2014 14:32:49 -0700 (PDT)
Date: Tue, 14 Oct 2014 17:32:46 -0400 (EDT)
Message-Id: <20141014.173246.921084057467310731.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee>
References: <20141013235219.GA11191@js1304-P5Q-DELUXE>
	<20141013.200416.641735303627599182.davem@davemloft.net>
	<alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: mroos@linux.ee
Date: Wed, 15 Oct 2014 00:19:36 +0300 (EEST)

>> > I'd like to know that your another problem is related to commit
>> > bf0dea23a9c0 ("mm/slab: use percpu allocator for cpu cache").  So,
>> > if the commit is reverted, your another problem is also gone
>> > completely?
>> 
>> The other problem has been present forever.
> 
> Umm? I am afraid I have been describing it badly. This random 
> SIGBUS+SIGSEGV problem is new - I have not seen it before.

Sorry, I thought it was the same bug that causes git corruptions
for you.  I misunderstood.

> I have been able to do kernel compiles for years on sparc64 (modulo 
> specific bugs in specific configurations) and 3.17 + start/end swap 
> patch seems also stable for most machine. With yesterdays git + align 
> patch, it dies with SIGBUS multiple times during compilation so it's a 
> new regression for me.
> 
> Will try reverting that commit tomorrow.

If that fails, please try to bisect, it will help us a lot.

> My only other current sparc64 problems that I am seeing - V210/V440 die 
> during bootup if compiled with gcc 4.9 and V480 dies with FATAL 
> exceptions during bootups since previous kernel release. Maybe also 
> exit_mmap warning - I do not know if they have been fixed, I see them 
> rarely.

The gcc-4.9 case is interesting, are you saying that a gcc-4.9 compiled
kernel works fine on other systems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
