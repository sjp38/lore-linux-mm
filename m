Date: Thu, 15 Mar 2007 21:01:59 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-ID: <20070315200159.GC19625@wotan.suse.de>
References: <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de> <Pine.LNX.4.64.0703151719380.32335@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703151719380.32335@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Chuck Ebbert <cebbert@redhat.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, Miquel van Smoorenburg <miquels@cistron.nl>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 05:44:01PM +0000, Hugh Dickins wrote:
> On Thu, 15 Mar 2007, Nick Piggin wrote:
> > On Thu, Mar 15, 2007 at 11:56:59AM -0400, Chuck Ebbert wrote:
> > > Ashif Harji wrote:
> > > > 
> > > > This patch unconditionally calls mark_page_accessed to prevent pages,
> > > > especially for small files, from being evicted from the page cache
> > > > despite frequent access.
> > > > 
> > > > Signed-off-by: Ashif Harji <asharji@beta.uwaterloo.ca>
> 
> Yeah, yeah, I'm not a real mman, I don't have my own patch and
> website for this ;) but I'm old, let me mumble some history...
> 
> Ashif's patch would take us back to 2.4.10 when mark_page_accessed
> was introduced: in 2.4.11 someone (probably Andrea) immediately
> added a !offset || !filp->f_reada condition on it there, which
> remains in 2.4 to this day.  That _probably_ means that Ashif's
> patch is suboptimal, and that your !offset patch is good.
> 
> f_reada went away in 2.5.8, and the !offset condition remained
> until 2.6.11, when Miquel (CC'ed) replaced it by today's prev_index
> condition.  His changelog entry appended below.  Since it's Miquel
> who removed the !offset condition, he should be consulted on its
> reintroduction.

Yeah I did go back and check up on that changelog, because I knew
we had a !offset check there at one stage, which is immune to this
problem (or at least can handle it a little better).

I suspect that Miquel was probably more interested in _increasing_
mark_page_accessed coverage with his new condition than restricting
it from the !offset cases.

Thanks for digging it up and posting here, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
