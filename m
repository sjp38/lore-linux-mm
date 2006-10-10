Date: Tue, 10 Oct 2006 11:23:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010092343.GA5492@wotan.suse.de>
References: <20061009232714.b52f678d.akpm@osdl.org> <20061010063900.GB25500@wotan.suse.de> <20061010065217.GC25500@wotan.suse.de> <20061010000652.bed6f901.akpm@osdl.org> <20061010072129.GB14557@wotan.suse.de> <20061010010742.50cbe1b1.akpm@osdl.org> <20061010081820.GA24748@wotan.suse.de> <20061010014114.75c424f0.akpm@osdl.org> <20061010084931.GB24748@wotan.suse.de> <20061010020726.c2f1a51c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061010020726.c2f1a51c.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2006 at 02:07:26AM -0700, Andrew Morton wrote:
> On Tue, 10 Oct 2006 10:49:31 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > > > but that is a bug in truncate and I have some patches to fix them.
> > > > 
> > > > But anyone who has done a get_user_pages, AFAIKS, can later run a
> > > > set_page_dirty on the pages.
> > > 
> > > Most (all?) callers are (and should be) using set_page_dirty_lock().
> > 
> > They don't, and I haven't checked but I doubt it is because they
> > always have the page locked.
> 
> I don't understand that.  If they're using get_user_pages() then they're probably _not_
> locking the page, and they should be using set_page_dirty_lock().
> 
> If they _are_ locking the page, and running set_page_dirty() inside that
> lock_page() then fine.

The requirement (commented fairly clearly on top of set_page_dirty_lock)
is for the mapping to be pinned, whether by page lock or some other means.

I'm not saying you're wrong because I haven't gone through everything,
have you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
