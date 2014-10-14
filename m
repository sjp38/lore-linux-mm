Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5DF6B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 17:19:38 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so8939839lbv.38
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 14:19:38 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id l1si28081634lbj.70.2014.10.14.14.19.36
        for <linux-mm@kvack.org>;
        Tue, 14 Oct 2014 14:19:37 -0700 (PDT)
Date: Wed, 15 Oct 2014 00:19:36 +0300 (EEST)
From: mroos@linux.ee
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <20141013.200416.641735303627599182.davem@davemloft.net>
Message-ID: <alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee>
References: <20141012.132012.254712930139255731.davem@davemloft.net> <alpine.LRH.2.11.1410132320110.9586@adalberg.ut.ee> <20141013235219.GA11191@js1304-P5Q-DELUXE> <20141013.200416.641735303627599182.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> > I'd like to know that your another problem is related to commit
> > bf0dea23a9c0 ("mm/slab: use percpu allocator for cpu cache").  So,
> > if the commit is reverted, your another problem is also gone
> > completely?
> 
> The other problem has been present forever.

Umm? I am afraid I have been describing it badly. This random 
SIGBUS+SIGSEGV problem is new - I have not seen it before.

I have been able to do kernel compiles for years on sparc64 (modulo 
specific bugs in specific configurations) and 3.17 + start/end swap 
patch seems also stable for most machine. With yesterdays git + align 
patch, it dies with SIGBUS multiple times during compilation so it's a 
new regression for me.

Will try reverting that commit tomorrow.

My only other current sparc64 problems that I am seeing - V210/V440 die 
during bootup if compiled with gcc 4.9 and V480 dies with FATAL 
exceptions during bootups since previous kernel release. Maybe also 
exit_mmap warning - I do not know if they have been fixed, I see them 
rarely.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
