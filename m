Subject: Re: [patch] fs: improved handling of page and buffer IO errors
From: Andi Kleen <andi@firstfloor.org>
References: <20081021112137.GB12329@wotan.suse.de>
Date: Tue, 21 Oct 2008 18:16:24 +0200
In-Reply-To: <20081021112137.GB12329@wotan.suse.de> (Nick Piggin's message of "Tue, 21 Oct 2008 13:21:37 +0200")
Message-ID: <87mygxexev.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

> IO error handling in the core mm/fs still doesn't seem perfect, but with
> the recent round of patches and this one, it should be getting on the
> right track.
>
> I kind of get the feeling some people would rather forget about all this
> and brush it under the carpet. Hopefully I'm mistaken, but if anybody
> disagrees with my assertion that error handling, and data integrity
> semantics are first-class correctness issues, and therefore are more
> important than all other non-correctness problems... speak now and let's
> discuss that, please.
>
> Otherwise, unless anybody sees obvious problems with this, hopefully it
> can go into -mm for some wider testing (I've tested it with a few filesystems
> so far and no immediate problems)

I think the first step to get these more robust in the future would be to
have a standard regression test testing these paths.  Otherwise it'll
bit-rot sooner or later again.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
