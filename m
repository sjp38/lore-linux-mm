Message-ID: <3C8652CE.47182A24@zip.com.au>
Date: Wed, 06 Mar 2002 09:33:02 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] struct page shrinkage
References: <OF8A6868F1.312B7C40-ON85256B74.005CB22E@pok.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Bulent Abali wrote:
> 
> >Rik van Riel wrote:
> >>
> >> +               clear_bit(PG_locked, &p->flags);
> >
> >Please don't do this.  Please use the macros.  If they're not
> >there, please create them.
> >
> >Bypassing the abstractions in this manner confounds people
> >who are implementing global locked-page accounting.
> >
> 
> Andrew,
> I have an application which needs to know the total number of locked and
> dirtied pages at any given time.  In which application locked-page
> accounting is done?   I don't see it in base 2.5.5.   Are there any patches
> or such that you can give pointers to?

This is in the ebulliently growing delayed-allocate and
buffer_head-bypass patches at

	http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.6-pre2/

The implementation you're looking for is in dalloc-10-core.patch:
mm.h and mm/page_alloc.c

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
