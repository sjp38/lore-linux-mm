Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4B468900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 19:06:57 -0400 (EDT)
Date: Mon, 29 Aug 2011 16:06:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix page-faults detection in swap-token logic
Message-Id: <20110829160637.bfc86e63.akpm@linux-foundation.org>
In-Reply-To: <20110827083201.21854.56111.stgit@zurg>
References: <20110827083201.21854.56111.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On Sat, 27 Aug 2011 12:32:01 +0300
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> After commit v2.6.36-5896-gd065bd8 "mm: retry page fault when blocking on disk transfer"
> we usually wait in page-faults without mmap_sem held, so all swap-token logic was broken,
> because it based on using rwsem_is_locked(&mm->mmap_sem) as sign of in progress page-faults.

If I'm interpreting this correctly, the thrash-handling logic has been
effectively disabled for a year and nobody noticed.

> This patch adds to mm_struct atomic counter of in progress page-faults for mm with swap-token.

We desperately need to delete some code from mm/.  This seems like a
great candidate.  Someone prove me wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
