Subject: Re: [PATCH 6/7] mm: add_active_or_unevictable into rmap
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <4924C6A7.6060506@redhat.com>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
	 <Pine.LNX.4.64.0811200120160.19216@blonde.site>
	 <4924C6A7.6060506@redhat.com>
Content-Type: text/plain
Date: Thu, 20 Nov 2008 10:18:56 -0500
Message-Id: <1227194336.6234.2.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-11-19 at 21:08 -0500, Rik van Riel wrote:
> Hugh Dickins wrote:
> > lru_cache_add_active_or_unevictable() and page_add_new_anon_rmap()
> > always appear together.  Save some symbol table space and some jumping
> > around by removing lru_cache_add_active_or_unevictable(), folding its
> > code into page_add_new_anon_rmap(): like how we add file pages to lru
> > just after adding them to page cache.
> > 
> > Remove the nearby "TODO: is this safe?" comments (yes, it is safe),
> > and change page_add_new_anon_rmap()'s address BUG_ON to VM_BUG_ON
> > as originally intended.

Hugh:  

Thanks for doing this [removing the comment].  I have a patch queued up
to do that, but recently swamped with other things.

Interesting that this is the first I've seen any comment on the comment,
tho'.  I would have thought the "//TODO"--a glaring violation of coding
style--would have at least provoked a comment on that account.

Lee
> > 
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
