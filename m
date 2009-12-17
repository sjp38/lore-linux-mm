Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3D7D66B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 14:47:31 -0500 (EST)
Date: Thu, 17 Dec 2009 13:46:50 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 01 of 28] compound_lock
In-Reply-To: <7418f21427a000ad1665.1261076404@v2.random>
Message-ID: <alpine.DEB.2.00.0912171346180.4640@router.home>
References: <patchbomb.1261076403@v2.random> <7418f21427a000ad1665.1261076404@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Dec 2009, Andrea Arcangeli wrote:

>  	if (unlikely(PageTail(page)))
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -108,6 +108,7 @@ enum pageflags {
>  #ifdef CONFIG_MEMORY_FAILURE
>  	PG_hwpoison,		/* hardware poisoned page. Don't touch */
>  #endif
> +	PG_compound_lock,
>  	__NR_PAGEFLAGS,

Eats up a rare page bit.

#ifdef CONFIG_TRANSP_HUGE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
