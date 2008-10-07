Date: Tue, 07 Oct 2008 14:23:23 -0700 (PDT)
Message-Id: <20081007.142323.97501781.davem@davemloft.net>
Subject: Re: [PATCH 17/32] net: packet split receive api
From: David Miller <davem@davemloft.net>
In-Reply-To: <20081002131608.749239880@chello.nl>
References: <20081002130504.927878499@chello.nl>
	<20081002131608.749239880@chello.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 02 Oct 2008 15:05:21 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de
List-ID: <linux-mm.kvack.org>

> Add some packet-split receive hooks.
> 
> For one this allows to do NUMA node affine page allocs. Later on these hooks
> will be extended to do emergency reserve allocations for fragments.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

The individual driver changes get a bunch of rejects in the net-next-2.6
tree, and you also missed some drivers such as NIU that also should use
these new interfaces.

So what I did for now was add just the non-driver parts that add the
interfaces themselves.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
