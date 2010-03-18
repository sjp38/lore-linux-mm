Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BB2F06B00D7
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 07:12:53 -0400 (EDT)
Date: Thu, 18 Mar 2010 11:12:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/11] mm,migration: Take a reference to the anon_vma
	before migrating
Message-ID: <20100318111231.GJ12388@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-2-git-send-email-mel@csn.ul.ie> <20100317103434.4C8B.A69D9226@jp.fujitsu.com> <20100317114537.GF12388@csn.ul.ie> <alpine.DEB.2.00.1003171138070.27268@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003171138070.27268@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 11:38:54AM -0500, Christoph Lameter wrote:
> On Wed, 17 Mar 2010, Mel Gorman wrote:
> 
> > This is true, but I don't think such a change belongs in this patch
> > series. If this series gets merged, then it would be sensible to investigate
> > if refcounting anon_vma is a good idea or would it be a bouncing write-shared
> > cacheline mess.
> 
> SLAB_DESTROY_BY_RCU is there to avoid the cooling of hot cachelines by
> RCU.
> 

Then even if we move to a full ref-count, it might still be a good idea
to preserve the SLAB_DESTROY_BY_RCU.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
