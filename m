Date: Tue, 13 May 2008 08:45:51 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
In-Reply-To: <20080513080143.GB19870@wotan.suse.de>
Message-ID: <alpine.LFD.1.10.0805130844000.3019@woody.linux-foundation.org>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org> <20080506095138.GE10141@wotan.suse.de> <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org>
 <20080513080143.GB19870@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>


On Tue, 13 May 2008, Nick Piggin wrote:
> 
> No, *everyone* (except arch-only non-alpha developer) needs to know about
> it.

Umm. In architecture files, by definition, only alpha needs to know about 
it.

That was very much an architecture-specific file: we're talking about 
asm-x86/pgtable_32.h here.

> x86 especially is a reference and often is a proving ground for code that
> becomes generic, so I'd say even x86 developers should need to know about
> it too.

And in reference files that are architecture-specific, there is absolutely 
*no point* in ever having read_barrier_depends(). Because even if another 
architecture copies it, it's better off without it.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
