Received: by el-out-1112.google.com with SMTP id y26so61644ele.4
        for <linux-mm@kvack.org>; Thu, 10 Apr 2008 09:17:45 -0700 (PDT)
Message-ID: <84144f020804100917y44ebc18an3e4afe3ac7052e8a@mail.gmail.com>
Date: Thu, 10 Apr 2008 19:17:44 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 04/18] SLUB: Sort slab cache list and establish maximum objects for defrag slabs
In-Reply-To: <20080407233001.3e1e5147.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080404230158.365359425@sgi.com>
	 <20080404230226.577197795@sgi.com>
	 <20080407231113.855e2ba3.akpm@linux-foundation.org>
	 <84144f020804072317g5b2b9f42yb300cad9a4258a15@mail.gmail.com>
	 <20080407233001.3e1e5147.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Tue, Apr 8, 2008 at 9:30 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>  > >  What the heck is oo_objects()?
>  >
>  > It's from the variable order patches. A cache has two orders: default
>  > order and the minimum order that we fall back to if default order
>  > allocations fail. We also have the same values for the number of
>  > objects per slab packed in a struct kmem_cache_order_objects. But yeah
>  > it's a terrible name...
>
>  umm, the phrase "what is X" is akpmese for "X should have been documented,
>  please fix".
>
>  I guess I should be explicit about that.

I looked at fixing this and noticed struct kmem_cache_order_object has
the following nice comment on top of it:

/*
 * Word size structure that can be atomically updated or read and that
 * contains both the order and the number of objects that a slab of the
 * given order would contain.
 */

Is that sufficient for you or do you want me to add kerneldoc style
comments on top of the actual oo_order() and oo_objects() functions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
