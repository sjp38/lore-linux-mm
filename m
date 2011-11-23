Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C58CE6B00CA
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 08:23:30 -0500 (EST)
Date: Wed, 23 Nov 2011 14:25:56 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH v2 1/3] mm: more intensive memory corruption debug
Message-ID: <20111123132555.GB7943@redhat.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
 <20111122135608.42686f14.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111122135608.42686f14.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>

On Tue, Nov 22, 2011 at 01:56:08PM -0800, Andrew Morton wrote:
> On Fri, 18 Nov 2011 17:25:05 +0100
> Stanislaw Gruszka <sgruszka@redhat.com> wrote:
> I added this:
> 
>   The default value of debug_guardpage_minorder is zero: no change
>   from current behaviour.
> 
> correct?
Yes,

> > +static inline void clear_page_guard_flg(struct page *page)
> > +{
> > +	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
> > +}
> 
> Why is it safe to use the non-atomic bitops here.
Clearing/setting flag is done only in __free_one_page()/expand(),
so operations are protected by zone->lock.

> Please verify that CONFIG_WANT_PAGE_DEBUG_FLAGS is always reliably
> enabled when this feature is turned on.
Change in mm/Kconfig.debug assures that CONFIG_WANT_PAGE_DEBUG_FLAGS is
set whenever CONFIG_DEBUG_PAGEALLOC is. 

> Some changes I made - please review.
Look good, thanks Andrew!

Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
