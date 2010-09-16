Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC7686B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 17:08:38 -0400 (EDT)
Date: Thu, 16 Sep 2010 23:08:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix swapin race condition
Message-ID: <20100916210835.GV5981@random.random>
References: <20100903153958.GC16761@random.random>
 <alpine.LSU.2.00.1009051926330.12092@sister.anvils>
 <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com>
 <20100915234237.GR5981@random.random>
 <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
 <20100916210349.GU5981@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100916210349.GU5981@random.random>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 11:03:49PM +0200, Andrea Arcangeli wrote:
> If I'm missing something a trace of the exact scenario would help to
> clarify your point.

Also supposing I'm right, I wouldn't mind if you add a
VM_BUG_ON(page_private(page) != entry.val) in the "pte_same == true"
path, just to be sure the invariant page_private(page) ==
pte_to_swp_entry(*page_table) doesn't ever break in a unnoticed way in
the future (I think it's unlikely to ever break but a VM_BUG_ON is
zero cost in production and it'll clarify the invariant). If instead
I'm wrong then just ahead fix it and I'll ack :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
