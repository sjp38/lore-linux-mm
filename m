Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3F5C6B0078
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 16:02:17 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1259006475.15619.16.camel@penberg-laptop>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop>  <4B067816.6070304@cs.helsinki.fi>
	 <1258729748.4104.223.camel@laptop> <1259002800.5630.1.camel@penberg-laptop>
	 <alpine.DEB.2.00.0911231329560.5617@router.home>
	 <1259005814.15619.14.camel@penberg-laptop>
	 <1259006475.15619.16.camel@penberg-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 23 Nov 2009 15:01:57 -0600
Message-ID: <1259010117.17871.473.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-11-23 at 22:01 +0200, Pekka Enberg wrote:
> On Mon, 2009-11-23 at 21:50 +0200, Pekka Enberg wrote:
> > On Mon, 23 Nov 2009, Pekka Enberg wrote:
> > > > That turns out to be _very_ hard. How about something like the following
> > > > untested patch which delays slab_destroy() while we're under nc->lock.
> > 
> > On Mon, 2009-11-23 at 13:30 -0600, Christoph Lameter wrote:
> > > Code changes to deal with a diagnostic issue?
> > 
> > OK, fair enough. If I suffer permanent brain damage from staring at the
> > SLAB code for too long, I hope you and Matt will chip in to pay for my
> > medication.

You Europeans and your droll health care jokes.

> Maybe something like this untested patch fixes the issue...

This looks like a much better approach.

-- 
http://selenic.com : development and support for Mercurial and Linux


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
