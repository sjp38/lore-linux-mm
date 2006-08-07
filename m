Date: Mon, 7 Aug 2006 16:25:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs
 invalidate race?
In-Reply-To: <44D75526.4050108@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0608071620001.13736@blonde.wat.veritas.com>
References: <44CF3CB7.7030009@yahoo.com.au> <Pine.LNX.4.64.0608031526400.15351@blonde.wat.veritas.com>
 <44D74B98.3030305@yahoo.com.au> <44D75526.4050108@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Nick Piggin wrote:
> Nick Piggin wrote:
> > 
> > Generic pagecache doesn't have an mmap method, which is where
> > I stopped looking. I guess you could add the |= to filemap_nopage,
> > but that's much uglier.

You can't |= vm_flags in nopage, mmap_sem isn't exclusive there.
But what's the matter with generic_file_mmap?

> Hmm, I guess adding a new mmap method solely to set that flag
> would actually be cleaner. And it would allow any filesystems
> that override .nopage bug end up calling filemap_nopage could
> equivalently override their mmap but still call filemap_mmap.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
