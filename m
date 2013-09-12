Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 427BE6B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 02:51:14 -0400 (EDT)
Date: Thu, 12 Sep 2013 15:51:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 01/16] slab: correct pfmemalloc check
Message-ID: <20130912065138.GA8055@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1377161065-30552-2-git-send-email-iamjoonsoo.kim@lge.com>
 <000001410d6dd2ea-858fd952-3568-44e9-ac6a-070810b732d0-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001410d6dd2ea-858fd952-3568-44e9-ac6a-070810b732d0-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Wed, Sep 11, 2013 at 02:30:03PM +0000, Christoph Lameter wrote:
> On Thu, 22 Aug 2013, Joonsoo Kim wrote:
> 
> > And, therefore we should check pfmemalloc in page flag of first page,
> > but current implementation don't do that. virt_to_head_page(obj) just
> > return 'struct page' of that object, not one of first page, since the SLAB
> > don't use __GFP_COMP when CONFIG_MMU. To get 'struct page' of first page,
> > we first get a slab and try to get it via virt_to_head_page(slab->s_mem).
> 
> Maybe using __GFP_COMP would make it consistent across all allocators and
> avoid the issue? We then do only have to set the flags on the first page.

Yes, you are right. It can be solved by using __GFP_COMP.
But I made this patch to clarify the problem in current code and to
be merged seperately.

If I solve the problem with __GFP_COMP which is implemented in [09/16]
of this patchset, it would also weaken the purpose of that patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
