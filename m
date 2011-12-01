Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 305EF6B0047
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 17:14:25 -0500 (EST)
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id E9EFA21FC3
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 17:14:22 -0500 (EST)
Date: Thu, 1 Dec 2011 14:13:37 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 01/11] mm: export vmalloc_sync_all symbol to GPL modules
Message-ID: <20111201221337.GB3365@kroah.com>
References: <1322775683-8741-1-git-send-email-mathieu.desnoyers@efficios.com>
 <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
 <20111201215700.GA16782@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111201215700.GA16782@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, devel@driverdev.osuosl.org, lttng-dev@lists.lttng.org, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, David McCullough <davidm@snapgear.com>, D Jeff Dionne <jeff@uClinux.org>, Greg Ungerer <gerg@snapgear.com>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 01, 2011 at 04:57:00PM -0500, Christoph Hellwig wrote:
> On Thu, Dec 01, 2011 at 04:41:13PM -0500, Mathieu Desnoyers wrote:
> > LTTng needs this symbol exported. It calls it to ensure its tracing
> > buffers and allocated data structures never trigger a page fault. This
> > is required to handle page fault handler tracing and NMI tracing
> > gracefully.
> 
> We:
> 
>  a) don't export symbols unless they have an intree-user

lttng is now in-tree in the drivers/staging/ area.  See linux-next for
details if you are curious.

>  b) especially don't export something as lowlevel as this one.

Mathieu, there's nothing else you can do to get this information?  Or
does lttng really want such lowlevel data?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
