Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA926B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 07:22:06 -0500 (EST)
Date: Mon, 14 Nov 2011 13:23:20 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 2/4] mm: more intensive memory corruption debug
Message-ID: <20111114122319.GC2513@redhat.com>
References: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
 <1321014994-2426-2-git-send-email-sgruszka@redhat.com>
 <20111111142953.GM3083@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111111142953.GM3083@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>

On Fri, Nov 11, 2011 at 02:29:53PM +0000, Mel Gorman wrote:
> > --- a/mm/Kconfig.debug
> > +++ b/mm/Kconfig.debug
> > @@ -4,6 +4,7 @@ config DEBUG_PAGEALLOC
> >  	depends on !HIBERNATION || ARCH_SUPPORTS_DEBUG_PAGEALLOC && !PPC && !SPARC
> >  	depends on !KMEMCHECK
> >  	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
> > +	select WANT_PAGE_DEBUG_FLAGS
> 
> Why not add PAGE_CORRUPT (or preferably PAGE_GUARD) in the same pattern
> as PAGE_POISONING already uses?

Additional CONFIG_PAGE_GUARD variable, would be duplicate of
CONFIG_DEBUG_PAGEALLOC. PAGE_POISONING is needed for compile
another file, no such thing would be needed with PAGE_GUARD,
hence I'm consider such variable useless.

Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
