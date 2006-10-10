Date: Mon, 9 Oct 2006 20:20:39 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-Id: <20061009202039.b6948a93.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org>
References: <20061010023654.GD15822@wotan.suse.de>
	<Pine.LNX.4.64.0610091951350.3952@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2006 20:06:05 -0700 (PDT)
Linus Torvalds <torvalds@osdl.org> wrote:

> On Tue, 10 Oct 2006, Nick Piggin wrote:
> >
> > This was triggered, but not the fault of, the dirty page accounting
> > patches. Suitable for -stable as well, after it goes upstream.
> 
> Applied. However, I wonder what protects "page_mapping()" here?

Nothing.  And I don't understand the (unchangelogged) switch from
page->mapping to page_mapping().

> I don't 
> think we hold the page lock anywhere, so "page->mapping" can change at any 
> time, no?

Yes.  The patch makes the race window a bit smaller.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
