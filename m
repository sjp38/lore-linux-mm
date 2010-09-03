Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 733236B007B
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 16:03:38 -0400 (EDT)
Date: Fri, 3 Sep 2010 13:02:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix swapin race condition
Message-Id: <20100903130259.b7dd8da5.akpm@linux-foundation.org>
In-Reply-To: <20100903153958.GC16761@random.random>
References: <20100903153958.GC16761@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Sep 2010 17:39:58 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> The pte_same check is reliable only if the swap entry remains pinned
> (by the page lock on swapcache). We've also to ensure the swapcache
> isn't removed before we take the lock as try_to_free_swap won't care
> about the page pin.

What were the end-user-observeable effects of this bug?

Do we think the fix should be backported into earlier kernels?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
