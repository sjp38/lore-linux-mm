Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC266B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:37:49 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <alpine.DEB.1.10.0901231032390.32253@qirst.com>
References: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>
	 <20090114150900.GC25401@wotan.suse.de>
	 <20090114152207.GD25401@wotan.suse.de>
	 <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>
	 <20090114155923.GC1616@wotan.suse.de>
	 <Pine.LNX.4.64.0901141219140.26507@quilx.com>
	 <20090115061931.GC17810@wotan.suse.de>
	 <Pine.LNX.4.64.0901151434150.28387@quilx.com>
	 <20090116034356.GM17810@wotan.suse.de>
	 <Pine.LNX.4.64.0901161509160.27283@quilx.com>
	 <20090119061856.GB22584@wotan.suse.de>
	 <alpine.DEB.1.10.0901211903540.18367@qirst.com>
	 <1232616430.14549.11.camel@penberg-laptop>
	 <1232616638.11429.131.camel@ymzhang>
	 <1232616792.14549.19.camel@penberg-laptop>
	 <alpine.DEB.1.10.0901231032390.32253@qirst.com>
Date: Fri, 23 Jan 2009 17:37:45 +0200
Message-Id: <1232725065.6094.92.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009, Pekka Enberg wrote:
> > That is, a list of pages that could be returned to the page allocator
> > but are pooled in SLUB to avoid the page allocator overhead. Note that
> > this will not help allocators that trigger page allocator pass-through.

On Fri, 2009-01-23 at 10:32 -0500, Christoph Lameter wrote:
> We use the partial list for that.

Even if the slab is totally empty?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
