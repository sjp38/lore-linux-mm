Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA699000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 17:10:31 -0400 (EDT)
Date: Mon, 20 Jun 2011 16:10:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 37072] New: Random BUG at
 include/linux/swapops.h:105
In-Reply-To: <20110620135353.cfe979ae.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1106201604360.17524@router.home>
References: <bug-37072-10286@https.bugzilla.kernel.org/> <20110620135353.cfe979ae.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, luke-jr+linuxbugs@utopios.org

On Mon, 20 Jun 2011, Andrew Morton wrote:

> handle_mm_fault
> ->handle_pte_fault
>   ->do_swap_page
>     ->migration_entry_wait
>       ->migration_entry_to_page
>         ->BUG_ON(!PageLocked(p))
>
> How is this supposed to ever work?

A page is always locked during migration. Thus a migration entry can
only exist while a page is locked. The migration entries purpose is
to hold off establishing new references to a page that is locked.
See unmap_and_move().

Looks like some of the recent patches may cause an unlock the page without
removal of the migration entry?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
