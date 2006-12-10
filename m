Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id kBAFJZmD112638
	for <linux-mm@kvack.org>; Sun, 10 Dec 2006 15:19:35 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBAFJYn62789512
	for <linux-mm@kvack.org>; Sun, 10 Dec 2006 16:19:34 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBAFJYUm004578
	for <linux-mm@kvack.org>; Sun, 10 Dec 2006 16:19:34 +0100
Date: Sun, 10 Dec 2006 16:19:31 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2
Message-ID: <20061210151931.GB28442@osiris.ibm.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com> <457C0D86.70603@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <457C0D86.70603@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

> I have to say that I have generally been a virtual memap sceptic.  It
> seems complex and any testing I have done or seen doesn't seem to show
> any noticible performance benefit.
> 
> That said I do like the general thrust of this patch set.  There is
> basically no architecture specific component for this implementation
> other than specifying the base address.  This seems worth of testing
> (and I see akpm has already slurped this up) good.
> 
> Would we expect to see this replace the existing ia64 implementation in
> the long term?  I'd hate to see us having competing implementations
> here.  Also Heiko would this framework with your s390 requirements for
> vmem_map, I know that you have a particularly challenging physical
> layout?  It would be great to see just one of these in the kernel.

Hmm.. this implementation still requires sparsemem. Maybe it would be
possible to implement a generic vmem_map infrastructure that works with
and without sparsemem?
I would be more than happy to get rid of the s390 specific vmem_map
implementation (it is merged in the meantime).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
