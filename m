Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DCFD36B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 22:35:24 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o862ZNk1012839
	for <linux-mm@kvack.org>; Sun, 5 Sep 2010 19:35:23 -0700
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by kpbe13.cbf.corp.google.com with ESMTP id o862ZLb3004127
	for <linux-mm@kvack.org>; Sun, 5 Sep 2010 19:35:22 -0700
Received: by pwj5 with SMTP id 5so1696098pwj.35
        for <linux-mm@kvack.org>; Sun, 05 Sep 2010 19:35:21 -0700 (PDT)
Date: Sun, 5 Sep 2010 19:35:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix swapin race condition
In-Reply-To: <20100903153958.GC16761@random.random>
Message-ID: <alpine.LSU.2.00.1009051926330.12092@sister.anvils>
References: <20100903153958.GC16761@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Sep 2010, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> The pte_same check is reliable only if the swap entry remains pinned
> (by the page lock on swapcache). We've also to ensure the swapcache
> isn't removed before we take the lock as try_to_free_swap won't care
> about the page pin.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

Yes, it's a great little find, and long predates the KSM hooks you've
had to adjust.  It does upset me (aesthetically) that the KSM case now
intrudes into do_swap_swap() much more than it used to; but I have not
come up with a better solution, so yes, let's go forward with this.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
