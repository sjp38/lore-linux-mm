Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C15C16B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:39:39 -0400 (EDT)
Date: Wed, 6 Oct 2010 23:42:00 +0200
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 2/2] HWPOISON: Attempt directed shrinking of slabs
Message-ID: <20101006214200.GA10386@gargoyle.ger.corp.intel.com>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org> <1286398930-11956-3-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1010061618470.8083@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010061618470.8083@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 04:26:47PM -0500, Christoph Lameter wrote:
> On Wed, 6 Oct 2010, Andi Kleen wrote:
> 
> > When a slab page is found try to shrink the specific slab first
> > before trying to shrink all slabs and call other shrinkers.
> > This can be done now using the new kmem_page_cache() call.
> 
> What you really would need here is targeted reclaim or the ability to move
> objects into other slabs.

Yes I know, but that is the first step.

> The likelyhood of the shaking having any effect
> is quite low.

Depends on the workload I guess.

> 
> The calling of the shrinkers is much more effective but it only works for
> certain slabs. This is a broad shot against all slabs. It would be best to
> call the fs shrinkers before kmem_cache_shrink(). You have to call
> kmem_cache_shrink afterwards anyways because the slabs may keep recently
> emptied slab pages around. The fs shrinkers may have evicted the objects
> but the empty slab page is still around.

We currently call the shrinking in a loop, similar to other users.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
