Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC2866B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 02:34:27 -0400 (EDT)
Date: Thu, 7 Oct 2010 08:34:23 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] SLAB: Add function to get slab cache for a page
Message-ID: <20101007063423.GB5010@basil.fritz.box>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org>
 <1286398930-11956-2-git-send-email-andi@firstfloor.org>
 <alpine.DEB.2.00.1010061640240.8083@router.home>
 <4CAD5C00.2020403@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CAD5C00.2020403@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, mpm@selenic.com, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 08:34:56AM +0300, Pekka Enberg wrote:
> On 10/7/10 12:42 AM, Christoph Lameter wrote:
> >On Wed, 6 Oct 2010, Andi Kleen wrote:
> >
> >>+struct kmem_cache *kmem_page_cache(struct page *p);
> >
> >That sounds as if we do something with the page cache.
> >
> >kmem_cache_of_slab_page(struct page *)
> 
> kmem_page_to_cache(), for example.

I changed it now to the name Christoph suggested.
-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
