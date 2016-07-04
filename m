Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BED576B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 01:26:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 143so373783327pfx.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 22:26:39 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g185si2124077pfc.294.2016.07.03.22.26.38
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 22:26:39 -0700 (PDT)
Date: Mon, 4 Jul 2016 14:29:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] mm/page_owner: track page free call chain
Message-ID: <20160704052955.GD14840@js1304-P5Q-DELUXE>
References: <20160702161656.14071-1-sergey.senozhatsky@gmail.com>
 <20160702161656.14071-4-sergey.senozhatsky@gmail.com>
 <20160704045714.GC14840@js1304-P5Q-DELUXE>
 <20160704050730.GC898@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160704050730.GC898@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 04, 2016 at 02:07:30PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (07/04/16 13:57), Joonsoo Kim wrote:
> > On Sun, Jul 03, 2016 at 01:16:56AM +0900, Sergey Senozhatsky wrote:
> > > Introduce PAGE_OWNER_TRACK_FREE config option to extend page owner with
> > > free_pages() tracking functionality. This adds to the dump_page_owner()
> > > output an additional backtrace, that tells us what path has freed the
> > > page.
> > 
> > Hmm... Do you have other ideas to use this feature? Following example is
> > just to detect use-after-free and we have other good tools for it
> > (KASAN or DEBUG_PAGEALLOC) so I'm not sure whether it's useful or not.
> 
> there is no kasan for ARM32, for example (apart from the fact that
> it's really hard to use kasan sometimes due to its cpu cycles and
> memory requirements).

Hmm... for debugging purpose, KASAN provides many more things so IMO it's
better to implement/support KASAN in ARM32 rather than expand
PAGE_OWNER for free.

> 
> educate me, will DEBUG_PAGEALLOC tell us what path has triggered the
> extra put_page()? hm... does ARM32 provide ARCH_SUPPORTS_DEBUG_PAGEALLOC?

Hmm... Now, I notice that PAGE_OWNER_TRACK_FREE will detect
double-free rather than use-after-free. DEBUG_PAGEALLOC doesn't catch
double-free but it can be implemented easily. In this case, we can
show call path for second free.

AFAIK, ARM32 doesn't support ARCH_SUPPORTS_DEBUG_PAGEALLOC.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
