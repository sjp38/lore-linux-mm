Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE9686B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 18:00:22 -0500 (EST)
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id D11BF21DAC
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 18:00:20 -0500 (EST)
Date: Thu, 1 Dec 2011 15:00:07 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 01/11] mm: export vmalloc_sync_all symbol to GPL modules
Message-ID: <20111201230007.GE3716@kroah.com>
References: <1322775683-8741-1-git-send-email-mathieu.desnoyers@efficios.com>
 <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
 <20111201215700.GA16782@infradead.org>
 <20111201221337.GB3365@kroah.com>
 <20111201222803.GA10853@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111201222803.GA10853@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, devel@driverdev.osuosl.org, lttng-dev@lists.lttng.org, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, David McCullough <davidm@snapgear.com>, D Jeff Dionne <jeff@uClinux.org>, Greg Ungerer <gerg@snapgear.com>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 01, 2011 at 05:28:03PM -0500, Christoph Hellwig wrote:
> On Thu, Dec 01, 2011 at 02:13:37PM -0800, Greg KH wrote:
> > On Thu, Dec 01, 2011 at 04:57:00PM -0500, Christoph Hellwig wrote:
> > > On Thu, Dec 01, 2011 at 04:41:13PM -0500, Mathieu Desnoyers wrote:
> > > > LTTng needs this symbol exported. It calls it to ensure its tracing
> > > > buffers and allocated data structures never trigger a page fault. This
> > > > is required to handle page fault handler tracing and NMI tracing
> > > > gracefully.
> > > 
> > > We:
> > > 
> > >  a) don't export symbols unless they have an intree-user
> > 
> > lttng is now in-tree in the drivers/staging/ area.  See linux-next for
> > details if you are curious.
> 
> Eww - merging stuff without discussion on lkml is more than evil.

Do you really want discussing all staging driver crap on lkml?

Core changes, like this one, for stuff in staging should be done on
lkml, which is what this conversation is :)

> Either way, it was guaranteed that drivers/staging is considered out of
> tree for core code.

The zram and zcache code would tend to disagree with you there :)

> I'm defintively dead set against exporting anything for staging and
> opening that slippery slope.

How else should we handle something like this then?  Some code, this one
specifically, is trying to get merged, so taking it slowly, through
staging, and getting it reviewed and cleaned up better before it can go
into the "real" part of the kernel, is the whole goal here.

Here's a real need for a symbol that an existing, shipping, useful
kernel module is wanting to use.

If you can provide a way that this can be handled without such an
export, that does not require digging through the symbol table (which is
what it was doing and I rightfully objected to that), then please let us
know.

Otherwise, what are our alternatives here, to just forbid this code from
ever being merged?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
