Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7A36B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 09:12:10 -0400 (EDT)
Date: Wed, 12 Aug 2009 14:12:12 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] tracing, documentation: Add a document describing
	how to do some performance analysis with tracepoints
Message-ID: <20090812131212.GC19269@csn.ul.ie>
References: <1249918915-16061-1-git-send-email-mel@csn.ul.ie> <1249918915-16061-6-git-send-email-mel@csn.ul.ie> <1250039059.4838.13.camel@pc-fernando>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1250039059.4838.13.camel@pc-fernando>
Sender: owner-linux-mm@kvack.org
To: Fernando Carrijo <fcarrijo@yahoo.com.br>
Cc: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 11, 2009 at 10:04:19PM -0300, Fernando Carrijo wrote:
> > <SNIP>
> > +At a glance, it looks like the time is being spent copying pixmaps to
> > +the card.  Further investigation would be needed to determine why pixmaps
> > +are being copied around so much but a starting point would be to take an
> > +ancient build of libpixmap out of the library path where it was totally
>                     ^^^^^^^^^
> 
> libpixman, right?
> 

Yep. Thanks

> > +forgotten about from months ago!
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
