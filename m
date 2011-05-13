Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EEE9E6B0023
	for <linux-mm@kvack.org>; Fri, 13 May 2011 10:48:26 -0400 (EDT)
Date: Fri, 13 May 2011 09:48:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: Add statistics for this_cmpxchg_double failures
In-Reply-To: <alpine.DEB.2.00.1105121257550.2407@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1105130947560.24193@router.home>
References: <alpine.DEB.2.00.1103221333130.16870@router.home> <alpine.DEB.2.00.1105111349350.9346@chino.kir.corp.google.com> <alpine.DEB.2.00.1105120943570.24560@router.home> <alpine.DEB.2.00.1105121257550.2407@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Thu, 12 May 2011, David Rientjes wrote:

> On Thu, 12 May 2011, Christoph Lameter wrote:
>
> > > I see this has been merged as 4fdccdfbb465, but it seems pretty pointless
> > > unless you export the data to userspace with the necessary STAT_ATTR() and
> > > addition in slab_attrs.
> >
> > Right that slipped into a later patch that only dealt with statistics. But
> > I will fold that into the earlier patch.
> >
>
> I think since CMPXCHG_DOUBLE_CPU_FAIL is already merged as 4fdccdfbb465
> that my patch should be merged to export it?

Sure. I have no objections.

Acked-by: Christoph Lameter <cl@linux.com>

> Not sure what patch you intend to fold this into.

Into the statistics patch for the lockless slowpaths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
