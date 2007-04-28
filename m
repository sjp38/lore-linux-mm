Date: Sat, 28 Apr 2007 23:06:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
In-Reply-To: <20070428141024.887342bd.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704282300080.2223@blonde.wat.veritas.com>
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>
 <46338AEB.2070109@imap.cc> <20070428141024.887342bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tilman Schmidt <tilman@imap.cc>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Apr 2007, Andrew Morton wrote:
> 
> It seems wildly screwed up that we have a PageReserved() page with a pfn of
> zero (!) which claims to be in a reiserfs mapping, only it isn't attached
> to a reiserfs file.  How the heck did that happen?

It's "simply" that it somehow got a spurious page table entry 00000001.
Great that it's so reproducible, I take that to mean this one is not
bad RAM.  Your request for a bisection is just what we want, thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
