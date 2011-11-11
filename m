Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 04B936B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 09:46:33 -0500 (EST)
Date: Fri, 11 Nov 2011 08:46:29 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] slub: min order when corrupt_dbg
In-Reply-To: <1321014994-2426-4-git-send-email-sgruszka@redhat.com>
Message-ID: <alpine.DEB.2.00.1111110845260.3006@router.home>
References: <1321014994-2426-1-git-send-email-sgruszka@redhat.com> <1321014994-2426-4-git-send-email-sgruszka@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 11 Nov 2011, Stanislaw Gruszka wrote:

> Disable slub debug facilities and allocate slabs at minimal order when
> corrupt_dbg > 0 to increase probability to catch random memory
> corruption by cpu exception.

Just setting slub_max_order to zero on boot has the same effect that all
of this here. Settug slub_max_order would only require a small hunk in
kmem_cache_init.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
