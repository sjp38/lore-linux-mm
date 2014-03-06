Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E29D66B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 16:56:37 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so3106604pdj.12
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 13:56:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qy5si6169642pab.224.2014.03.06.13.56.36
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 13:56:36 -0800 (PST)
Date: Thu, 6 Mar 2014 13:56:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [merged]
 mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch removed from -mm
 tree
Message-Id: <20140306135635.6999d703429afb7fd3949304@linux-foundation.org>
In-Reply-To: <20140306214927.GB11171@cmpxchg.org>
References: <5318dca5.AwhU/92X21JgbpdE%akpm@linux-foundation.org>
	<20140306214927.GB11171@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: stable@kernel.org, riel@redhat.com, mgorman@suse.de, jstancek@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Mar 2014 16:49:27 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Mar 06, 2014 at 12:37:57PM -0800, akpm@linux-foundation.org wrote:
> > Subject: [merged] mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch removed from -mm tree
> > To: hannes@cmpxchg.org,jstancek@redhat.com,mgorman@suse.de,riel@redhat.com,stable@kernel.org,mm-commits@vger.kernel.org
> > From: akpm@linux-foundation.org
> > Date: Thu, 06 Mar 2014 12:37:57 -0800
> > 
> > 
> > The patch titled
> >      Subject: mm: page_alloc: exempt GFP_THISNODE allocations from zone fairness
> > has been removed from the -mm tree.  Its filename was
> >      mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch
> > 
> > This patch was dropped because it was merged into mainline or a subsystem tree
> 
> Would it make sense to also merge
> 
> mm-fix-gfp_thisnode-callers-and-clarify.patch
> 
> at this point?  It's not as critical as the GFP_THISNODE exemption,
> which is why I didn't tag it for stable, but it's a bugfix as well.

Changelog fail!

: GFP_THISNODE is for callers that implement their own clever fallback to
: remote nodes, and so no direct reclaim is invoked.  There are many current
: users that only want node exclusiveness but still want reclaim to make the
: allocation happen.  Convert them over to __GFP_THISNODE and update the
: documentation to clarify GFP_THISNODE semantics.

what bug does it fix and what are the user-visible effects??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
