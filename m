Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 337466B0073
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 04:32:51 -0400 (EDT)
Date: Wed, 27 Jun 2012 09:32:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 09/16] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120627083246.GF8271@suse.de>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-10-git-send-email-mgorman@suse.de>
 <20120626152734.GA6509@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120626152734.GA6509@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, Jun 26, 2012 at 05:27:34PM +0200, Sebastian Andrzej Siewior wrote:
> On Fri, Jun 22, 2012 at 03:30:36PM +0100, Mel Gorman wrote:
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 5c9ca2b..159dccc 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -271,6 +271,9 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
> >  int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
> >  EXPORT_SYMBOL(sysctl_optmem_max);
> >  
> > +struct static_key memalloc_socks = STATIC_KEY_INIT_FALSE;
> > +EXPORT_SYMBOL_GPL(memalloc_socks);
> > +
> 
> This is used via sk_memalloc_socks() by SLAB.
> 
> From 3da9ab9972845974da114c5a6624335e6371b2d5 Mon Sep 17 00:00:00 2001
> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> Date: Tue, 26 Jun 2012 17:18:20 +0200
> Subject: [PATCH] export sk_memalloc_socks() only with CONFIG_NET
> 
> |mm/built-in.o: In function `atomic_read':
> |include/asm/atomic.h:25: undefined reference to `memalloc_socks'
> |include/asm/atomic.h:25: undefined reference to `memalloc_socks'
> |include/asm/atomic.h:25: undefined reference to `memalloc_socks'
> |include/asm/atomic.h:25: undefined reference to `memalloc_socks'
> |include/asm/atomic.h:25: undefined reference to `memalloc_socks'
> |mm/built-in.o:include/asm/atomic.h:25: more undefined references to `memalloc_socks' follow
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Well caught. I had not tested build with !CONFIG_NET. I've folded in
this patch and the credits accordingly. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
