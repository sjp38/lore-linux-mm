Date: Wed, 29 Jun 2005 18:31:00 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [patch 2] mm: speculative get_page
Message-ID: <20050629163100.GA13336@elf.ucw.cz>
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au> <42BF9D86.90204@yahoo.com.au> <42C14662.40809@shadowen.org> <42C14D93.7090303@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42C14D93.7090303@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi!

> >There are a couple of bits which imply ownership such as PG_slab,
> >PG_swapcache and PG_reserved which to my mind are all exclusive.
> >Perhaps those plus the PG_free could be combined into a owner field.  I
> >am unsure if the PG_freeing can be 'backed out' if not it may also combine?
> 
> I think there are a a few ways that bits can be reclaimed if we
> start digging. swsusp uses 2 which seems excessive though may be
> fully justified. Can PG_private be replaced by (!page->private)?
> Can filesystems easily stop using PG_checked?

It is possible that swsusp could reduce its bit usage... Current stuff
works, but probably does not need strong atomicity guarantees, and
could use some bit combination...
								Pavel
-- 
teflon -- maybe it is a trademark, but it should not be.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
