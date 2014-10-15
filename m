Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 70CBA6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:11:37 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so1717727lbi.9
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 13:11:36 -0700 (PDT)
Received: from smtp2.it.da.ut.ee (smtp2.it.da.ut.ee. [2001:bb8:2002:500:20f:1fff:fe04:1bbb])
        by mx.google.com with ESMTP id wb3si12117643lbb.112.2014.10.15.13.11.35
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 13:11:35 -0700 (PDT)
Date: Wed, 15 Oct 2014 23:11:34 +0300 (EEST)
From: Meelis Roos <mroos@linux.ee>
Subject: Re: unaligned accesses in SLAB etc.
In-Reply-To: <20141015.143624.941838991598108211.davem@davemloft.net>
Message-ID: <alpine.LRH.2.11.1410152310080.11974@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee> <20141014.173246.921084057467310731.davem@davemloft.net> <alpine.LRH.2.11.1410151059520.8050@adalberg.ut.ee> <20141015.143624.941838991598108211.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

> >> The gcc-4.9 case is interesting, are you saying that a gcc-4.9 compiled
> >> kernel works fine on other systems?
> > 
> > Yes, all USII based systems work fine with Debian gcc-4.9, as does 
> > T2000. Of USIII* systems, V210 and V440 exhibit the boot hang with 
> > gcc-4.9 and V480 crashes wit FATAL exception during boot that is 
> > probably earlier than the gcc boot hang so I do not know about V480 and 
> > gcc-4.9. V240 not tested because of fan failures, V245 is in the queue 
> > for setup but not tested so far.
> 
> Ok, on the V210/V440 can you boot with "-p" on the kernel boot command
> line and post the log?  Let's start by seeing how far it gets, maybe
> we can figure out roughly where it dies.

http://www.spinics.net/lists/sparclinux/msg12238.html and 
http://www.spinics.net/lists/sparclinux/msg12468.html are my relevant 
posts about it. Should I get something more? It would be easy because of 
ALOM.

-- 
Meelis Roos (mroos@linux.ee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
