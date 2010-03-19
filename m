Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 19C286B00BE
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 05:00:09 -0400 (EDT)
Date: Fri, 19 Mar 2010 08:59:49 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
Message-ID: <20100319085949.GQ12388@csn.ul.ie>
References: <20100318094720.872F.A69D9226@jp.fujitsu.com> <20100318111436.GK12388@csn.ul.ie> <20100319152103.876F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100319152103.876F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 19, 2010 at 03:21:41PM +0900, KOSAKI Motohiro wrote:
> > > then, this logic depend on SLAB_DESTROY_BY_RCU, not refcount.
> > > So, I think we don't need your [1/11] patch.
> > > 
> > > Am I missing something?
> > > 
> > 
> > The refcount is still needed. The anon_vma might be valid, but the
> > refcount is what ensures that the anon_vma is not freed and reused.
> 
> please please why do we need both mechanism. now cristoph is very busy and I am
> de fact reviewer of page migration and mempolicy code. I really hope to understand
> your patch.
> 

As in, why not drop the RCU protection of anon_vma altogeter? Mainly, because I
think it would be reaching too far for this patchset and it should be done as
a follow-up. Putting the ref-count everywhere will change the cache-behaviour
of anon_vma more than I'd like to slip into a patchset like this. Secondly,
Christoph mentions that SLAB_DESTROY_BY_RCU is used to keep anon_vma cache-hot.
For these reasons, removing RCU from these paths and adding the refcount
in others is a patch that should stand on its own.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
