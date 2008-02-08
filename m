Date: Fri, 8 Feb 2008 15:42:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 2/2] Explicitly retry hugepage allocations
In-Reply-To: <20080208234031.GE27150@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0802081542300.4291@schroedinger.engr.sgi.com>
References: <20080206230726.GF3477@us.ibm.com> <20080206231243.GG3477@us.ibm.com>
 <Pine.LNX.4.64.0802061529480.22648@schroedinger.engr.sgi.com>
 <20080208171132.GE15903@us.ibm.com> <Pine.LNX.4.64.0802081117340.1654@schroedinger.engr.sgi.com>
 <20080208234031.GE27150@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: melgor@ie.ibm.com, apw@shadowen.org, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2008, Nishanth Aravamudan wrote:

> make higher order allocations coming from hugetlb.c use the __REPEAT
> logic I'm trying to add. If the method seems good in general, then we
> just need to mark other locations (SLUB allocation paths?) with
> __GFP_REPEAT. When slub_min_order <= PAGE_ALLOC_COSTLY_ORDER, then we
> shouldn't see any difference and when it is greater, we should hit the
> logic I added. Does that seem reasonable to you? I think it's a separate
> idea, though, and I'd prefer keeping it in a separate patch, if that's
> ok with you.

Fine with me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
