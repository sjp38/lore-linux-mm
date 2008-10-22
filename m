Date: Wed, 22 Oct 2008 12:31:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081022103112.GA27862@wotan.suse.de>
References: <20081021112137.GB12329@wotan.suse.de> <87mygxexev.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mygxexev.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 21, 2008 at 06:16:24PM +0200, Andi Kleen wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> > IO error handling in the core mm/fs still doesn't seem perfect, but with
> > the recent round of patches and this one, it should be getting on the
> > right track.
> >
> > I kind of get the feeling some people would rather forget about all this
> > and brush it under the carpet. Hopefully I'm mistaken, but if anybody
> > disagrees with my assertion that error handling, and data integrity
> > semantics are first-class correctness issues, and therefore are more
> > important than all other non-correctness problems... speak now and let's
> > discuss that, please.
> >
> > Otherwise, unless anybody sees obvious problems with this, hopefully it
> > can go into -mm for some wider testing (I've tested it with a few filesystems
> > so far and no immediate problems)
> 
> I think the first step to get these more robust in the future would be to
> have a standard regression test testing these paths.  Otherwise it'll
> bit-rot sooner or later again.

The problem I've had with testing is that it's hard to trigger a specific
path for a given error, because write IO especially can be quite non
deterministic, and the filesystem or kernel may give up at various points.

I agree, but I just don't know exactly how they can be turned into
standard tests. Some filesystems like XFS seem to completely shut down
quite easily on IO errors. Others like ext2 can't really unwind from
a failure in a multi-block operation (eg. allocating a block to an
inode) if an error is detected, and it just gets ignored.

I am testing, but mainly just random failure injections and seeing if
things go bug or go undetected etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
