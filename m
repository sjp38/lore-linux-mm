Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6247B6B0047
	for <linux-mm@kvack.org>; Sat,  4 Sep 2010 08:29:54 -0400 (EDT)
Date: Sat, 4 Sep 2010 14:29:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix swapin race condition
Message-ID: <20100904122949.GJ16761@random.random>
References: <20100903153958.GC16761@random.random>
 <20100903130259.b7dd8da5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903130259.b7dd8da5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 01:02:59PM -0700, Andrew Morton wrote:
> On Fri, 3 Sep 2010 17:39:58 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > The pte_same check is reliable only if the swap entry remains pinned
> > (by the page lock on swapcache). We've also to ensure the swapcache
> > isn't removed before we take the lock as try_to_free_swap won't care
> > about the page pin.
> 
> What were the end-user-observeable effects of this bug?

I found it by code review only.

> Do we think the fix should be backported into earlier kernels?

Considering I didn't see user-observable effects it's up to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
