Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7856D6B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 05:05:39 -0400 (EDT)
Date: Mon, 19 Apr 2010 10:05:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
Message-ID: <20100419090520.GN19264@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com> <20100414091825.0bacfe48.kamezawa.hiroyu@jp.fujitsu.com> <s2x84144f021004140523t3092f6cbge410ab4e15afac3e@mail.gmail.com> <alpine.DEB.2.00.1004161109070.7710@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004161109070.7710@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 11:10:01AM -0500, Christoph Lameter wrote:
> On Wed, 14 Apr 2010, Pekka Enberg wrote:
> 
> > Minchan, care to send a v2 with proper changelog and reviewed-by attributions?
> 
> Still wondering what the big deal about alloc_pages_node_exact is. Its not
> exact since we can fall back to another node. It is better to clarify the
> API for alloc_pages_node and forbid / clarify the use of -1.
> 

There should be a comment clarifing it now. I admit the naming fault is
mine. At the time, the intended meaning was "allocate pages from any node in
the fallback list and the caller knows exactly which node to start from". I
did not take into account that the meaning of "exact" depends on context.

With a comment clarifying the meaning, I do not think a rename is necessary.
However, I'd rather not see a mass renaming of functions like alloc_pages()
that have existed a long times. If nothing else, they are documented in books
like "Linux Device Drivers" so why make life harder on device authors than
it already is?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
