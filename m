Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 386826B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 03:27:09 -0400 (EDT)
Date: Mon, 23 May 2011 03:27:05 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Adding an ugliness in __read_cache_page()?
Message-ID: <20110523072705.GA3966@infradead.org>
References: <alpine.LSU.2.00.1105221518180.17400@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1105221518180.17400@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, May 22, 2011 at 03:25:31PM -0700, Hugh Dickins wrote:
> I find both ways ugly, but no nice alternative: introducing a new method
> when the known callers are already tied to tmpfs/ramfs seems over the top.

Calling into shmem directly is the less ugly variant.  Long term killing
that tmpfs abuse would be even better, but I already lost that fight
when it was initially added.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
