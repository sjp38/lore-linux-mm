Date: Tue, 07 Oct 2008 14:19:02 -0700 (PDT)
Message-Id: <20081007.141902.06048204.davem@davemloft.net>
Subject: Re: [PATCH 16/32] net: wrap sk->sk_backlog_rcv()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20081002131608.667433428@chello.nl>
References: <20081002130504.927878499@chello.nl>
	<20081002131608.667433428@chello.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 02 Oct 2008 15:05:20 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de
List-ID: <linux-mm.kvack.org>

> Wrap calling sk->sk_backlog_rcv() in a function. This will allow extending the
> generic sk_backlog_rcv behaviour.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Looks fine, applied to net-next-2.6, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
