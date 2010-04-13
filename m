Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A7E1E6B01F2
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 12:14:56 -0400 (EDT)
Date: Tue, 13 Apr 2010 17:14:22 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
Message-ID: <20100413161421.GH25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com> <20100413155253.GD25756@csn.ul.ie> <i2x28c262361004130901p9c34b49cu9c7ebd1a24de5ed9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <i2x28c262361004130901p9c34b49cu9c7ebd1a24de5ed9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 01:01:31AM +0900, Minchan Kim wrote:
> On Wed, Apr 14, 2010 at 12:52 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Wed, Apr 14, 2010 at 12:25:00AM +0900, Minchan Kim wrote:
> >> alloc_slab_page never calls alloc_pages_node with -1.
> >
> > Are you certain? What about
> >
> > __kmalloc
> >  -> slab_alloc (passed -1 as a node from __kmalloc)
> >    -> __slab_alloc
> >      -> new_slab
> >        -> allocate_slab
> >          -> alloc_slab_page
> >
> 
> Sorry for writing confusing changelog.
> 
> I means if node == -1 alloc_slab_page always calls alloc_pages.
> So we don't need redundant check.
> 

When the changelog is fixed up, feel free to add;

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
