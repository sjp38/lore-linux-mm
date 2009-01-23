Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 118E36B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:35:22 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7D14482C6A9
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:36:42 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1COP-Jajfi8S for <linux-mm@kvack.org>;
	Fri, 23 Jan 2009 10:36:42 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 29C6182C6C7
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:36:40 -0500 (EST)
Date: Fri, 23 Jan 2009 10:32:29 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <1232616430.14549.11.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0901231030470.32253@qirst.com>
References: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>  <20090114150900.GC25401@wotan.suse.de>  <20090114152207.GD25401@wotan.suse.de>  <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>  <20090114155923.GC1616@wotan.suse.de>
 <Pine.LNX.4.64.0901141219140.26507@quilx.com>  <20090115061931.GC17810@wotan.suse.de>  <Pine.LNX.4.64.0901151434150.28387@quilx.com>  <20090116034356.GM17810@wotan.suse.de>  <Pine.LNX.4.64.0901161509160.27283@quilx.com>  <20090119061856.GB22584@wotan.suse.de>
  <alpine.DEB.1.10.0901211903540.18367@qirst.com> <1232616430.14549.11.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009, Pekka Enberg wrote:

> On Wed, 2009-01-21 at 19:13 -0500, Christoph Lameter wrote:
> > No it cannot because in SLUB objects must come from the same page.
> > Multiple objects in a queue will only ever require a single page and not
> > multiple like in SLAB.
>
> There's one potential problem with "per-page queues", though. The bigger
> the object, the smaller the "queue" (i.e. less objects per page). Also,
> partial lists are less likely to help for big objects because they get
> emptied so quickly and returned to the page allocator. Perhaps we should
> do a small "full list" for caches with large objects?

Right thats why there is need for higher order allocs because that
increases the "queue" sizes. If the pages are larger then also the partial
lists will cover more ground. Much of the tuning in SLUB is the page size
setting (remember you can set the order for each slab in slub!). In
SLAB/SLQB the corresponding tuning is through the queue sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
