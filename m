Date: Sun, 7 Oct 2007 20:46:07 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 6/7] shmem_file_write is redundant
Message-ID: <20071007204607.23101e6f@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0710062146370.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
	<Pine.LNX.4.64.0710062146370.16223@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Oct 2007 21:47:48 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> With the new aops, the generic method uses shmem_write_end, which lets
> shmem_getpage find the right page: so now abandon shmem_file_write in
> favour of the generic method.  Yes, that does do several things that
> tmpfs hasn't really needed (notably balance_dirty_pages_ratelimited,
> which ramfs also calls); but more use of common code is preferable.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
