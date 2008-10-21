Date: Tue, 21 Oct 2008 17:30:24 +0100
From: steve@chygwyn.com
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081021163024.GB29653@fogou.chygwyn.com>
References: <20081021112137.GB12329@wotan.suse.de> <87mygxexev.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mygxexev.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

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
> 
> -Andi
>
I have a plan to (at some stage, when I get some time!) create some
mechanism which will allow the mounting of multiple GFS2 filesystems
on a single device, on the same node. i.e. like a cluster but multiple
mounts from a single node. Currently we can get half way there by
"cloning" a block device with dm, but our locking doesn't support that
configuration at the moment.

Given that, it should then be possible to run cluster tests on a single
node across several mounts of the same filesystem, and thus allow
much easier testing (there is of course no practical reason to allow
such a configuration aside from testing),

Steve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
