Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0F54C6B004A
	for <linux-mm@kvack.org>; Tue, 12 Jul 2011 13:53:29 -0400 (EDT)
Date: Tue, 12 Jul 2011 19:53:24 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: do_wp_page recheck PageKsm after obtaining the page_lock,
 pte_same not enough
Message-ID: <20110712175324.GS23227@redhat.com>
References: <20110712165003.GP23227@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110712165003.GP23227@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Johannes Weiner <jweiner@redhat.com>

On Tue, Jul 12, 2011 at 06:50:03PM +0200, Andrea Arcangeli wrote:
> Hi Hugh,
> 
> what do you think about this?

Ah I just noticed it couldn't happen so you can ignore the previous
patch... a second check is indeed inside reuse_swap_page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
