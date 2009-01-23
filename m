Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 001B26B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:57:10 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0231382C6D8
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:58:31 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jvd--9bGV1yB for <linux-mm@kvack.org>;
	Fri, 23 Jan 2009 10:58:26 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B921482C6DA
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 10:58:21 -0500 (EST)
Date: Fri, 23 Jan 2009 10:32:52 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <1232616792.14549.19.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0901231032390.32253@qirst.com>
References: <84144f020901140645o68328e01ne0e10ace47555e19@mail.gmail.com>  <20090114150900.GC25401@wotan.suse.de>  <20090114152207.GD25401@wotan.suse.de>  <84144f020901140730l747b4e06j41fb8a35daeaf6c8@mail.gmail.com>  <20090114155923.GC1616@wotan.suse.de>
 <Pine.LNX.4.64.0901141219140.26507@quilx.com>  <20090115061931.GC17810@wotan.suse.de>  <Pine.LNX.4.64.0901151434150.28387@quilx.com>  <20090116034356.GM17810@wotan.suse.de>  <Pine.LNX.4.64.0901161509160.27283@quilx.com>  <20090119061856.GB22584@wotan.suse.de>
  <alpine.DEB.1.10.0901211903540.18367@qirst.com>  <1232616430.14549.11.camel@penberg-laptop>  <1232616638.11429.131.camel@ymzhang> <1232616792.14549.19.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Nick Piggin <npiggin@suse.de>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009, Pekka Enberg wrote:

> That is, a list of pages that could be returned to the page allocator
> but are pooled in SLUB to avoid the page allocator overhead. Note that
> this will not help allocators that trigger page allocator pass-through.

We use the partial list for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
