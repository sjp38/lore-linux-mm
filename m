Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 4F2E06B0062
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:28:04 -0400 (EDT)
Date: Tue, 26 Jun 2012 17:27:34 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 09/16] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120626152734.GA6509@breakpoint.cc>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-10-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340375443-22455-10-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, Jun 22, 2012 at 03:30:36PM +0100, Mel Gorman wrote:
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5c9ca2b..159dccc 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -271,6 +271,9 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
>  int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
>  EXPORT_SYMBOL(sysctl_optmem_max);
>  
> +struct static_key memalloc_socks = STATIC_KEY_INIT_FALSE;
> +EXPORT_SYMBOL_GPL(memalloc_socks);
> +

This is used via sk_memalloc_socks() by SLAB.
