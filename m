Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 17AAB6B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:23:33 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C74D182C3BF
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:24:29 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YPpPT1B0PEAw for <linux-mm@kvack.org>;
	Tue,  8 Sep 2009 11:24:29 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 12EC882C3C5
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:24:03 -0400 (EDT)
Date: Tue, 8 Sep 2009 11:22:08 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <1252419602.7746.73.camel@twins>
Message-ID: <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1>
References: <20090908190148.0CC9.A69D9226@jp.fujitsu.com>  <1252405209.7746.38.camel@twins>  <20090908193712.0CCF.A69D9226@jp.fujitsu.com>  <1252411520.7746.68.camel@twins>  <alpine.DEB.1.10.0909081000100.15723@V090114053VZO-1>
 <1252419602.7746.73.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Peter Zijlstra wrote:

> There is _no_ functional difference between before and after, except
> less wakeups on cpus that don't have any __lru_cache_add activity.
>
> If there's pages on the per cpu lru_add_pvecs list it will be present in
> the mask and will be send a drain request. If its not, then it won't be
> send.

Ok I see.

A global cpu mask like this will cause cacheline bouncing. After all this
is a hot cpu path. Maybe do not set the bit if its already set
(which may be very frequent)? Then add some benchmarks to show that it
does not cause a regression on a 16p box (Nehalem) or so?






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
