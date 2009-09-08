Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D1F176B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 10:04:44 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D293182C38A
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 10:05:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FPYSWwUADe3b for <linux-mm@kvack.org>;
	Tue,  8 Sep 2009 10:05:33 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0011882C3AE
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 10:05:28 -0400 (EDT)
Date: Tue, 8 Sep 2009 10:03:42 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <1252411520.7746.68.camel@twins>
Message-ID: <alpine.DEB.1.10.0909081000100.15723@V090114053VZO-1>
References: <20090908190148.0CC9.A69D9226@jp.fujitsu.com>  <1252405209.7746.38.camel@twins>  <20090908193712.0CCF.A69D9226@jp.fujitsu.com> <1252411520.7746.68.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Peter Zijlstra wrote:

> This is about avoiding work when there is non, clearly when an
> application does use the kernel it creates work.

Hmmm. The lru draining in page migration is to reduce the number of pages
that are not on the lru to increase the chance of page migration to be
successful. A page on a per cpu list cannot be drained.

Reducing the number of cpus where we perform the drain results in
increased likelyhood that we cannot migrate a page because its on the per
cpu lists of a cpu not covered.

On the other hand if the cpu is offline then we know that it has no per
cpu pages. That is why I found the idea of the OFFLINE
scheduler attractive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
