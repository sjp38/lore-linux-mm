Date: Mon, 30 Jul 2001 20:33:40 +0100 (BST)
From: Mark Hemment <markhe@veritas.com>
Subject: Re: Can reverse VM locks?
In-Reply-To: <Pine.LNX.4.33L.0107301603120.5582-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0107302022250.13705-100000@alloc.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2001, Rik van Riel wrote:

> OK, I've been looking at the lock order reversal too,
> though for different reasons ;)
>
> On Mon, 2 Jul 2001 markhe@veritas.com wrote:
> > On Mon, 2 Jul 2001, Rik van Riel wrote:
> > > On Mon, 2 Jul 2001 markhe@veritas.com wrote:
> > >
> > > >   Anyone know of any places where reversing the lock ordering would break?
>
> Yes, very much true.  Now what I wanted to ask about:
> do you already have a patch which does this or should
> I write a patch which does the lock order reversal ?

  I did do it, only took a couple of hours, but didn't show any measurable
improvement on a four-way box so I put it on the back-burner.  It is
probably lying around on an off-lined disk somewhere - I'll try to dig it
out tomorrow (time for pub/home in the UK), or re-code it.

  Three points to note;
	1) Looked like it might allow for easily coding of per page-cache
	   line spinlocks (if we want to go there).
	2) I suspected the pagemap_lru_lock was still under heavy
	   contention (the reversal wouldn't have helped it).
	3) In filemap.c, the pagecache_lock and pagemap_lru_lock are far
	   too "close" - need to be L1 cached aligned.

Mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
