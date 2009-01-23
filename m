Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 853946B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:56:00 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 80CAE82C6DF
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:57:20 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qRiaTby0r-gm for <linux-mm@kvack.org>;
	Fri, 23 Jan 2009 10:57:20 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5BD0482C6F4
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:56:56 -0500 (EST)
Date: Fri, 23 Jan 2009 10:42:04 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <1232725065.6094.92.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0901231041230.32253@qirst.com>
References: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>  <20090114150900.GC25401@wotan.suse.de>  <20090114152207.GD25401@wotan.suse.de>  <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>  <20090114155923.GC1616@wotan.suse.de>
 <Pine.LNX.4.64.0901141219140.26507@quilx.com>  <20090115061931.GC17810@wotan.suse.de>  <Pine.LNX.4.64.0901151434150.28387@quilx.com>  <20090116034356.GM17810@wotan.suse.de>  <Pine.LNX.4.64.0901161509160.27283@quilx.com>  <20090119061856.GB22584@wotan.suse.de>
  <alpine.DEB.1.10.0901211903540.18367@qirst.com>  <1232616430.14549.11.camel@penberg-laptop>  <1232616638.11429.131.camel@ymzhang>  <1232616792.14549.19.camel@penberg-laptop>  <alpine.DEB.1.10.0901231032390.32253@qirst.com>
 <1232725065.6094.92.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jan 2009, Pekka Enberg wrote:

> On Thu, 22 Jan 2009, Pekka Enberg wrote:
> > > That is, a list of pages that could be returned to the page allocator
> > > but are pooled in SLUB to avoid the page allocator overhead. Note that
> > > this will not help allocators that trigger page allocator pass-through.
>
> On Fri, 2009-01-23 at 10:32 -0500, Christoph Lameter wrote:
> > We use the partial list for that.
>
> Even if the slab is totally empty?

The MIN_PARTIAL thingy can keep pages around even if the slab becomes
totally empty in order to avoid page allocator trips.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
