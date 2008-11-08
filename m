Date: Sat, 8 Nov 2008 09:37:13 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 0/9] vmalloc fixes and improvements
In-Reply-To: <20081108054144.GB24308@wotan.suse.de>
Message-ID: <alpine.LFD.2.00.0811080931540.3468@nehalem.linux-foundation.org>
References: <20081108021512.686515000@suse.de> <alpine.LFD.2.00.0811072109550.3468@nehalem.linux-foundation.org> <20081108054144.GB24308@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>


On Sat, 8 Nov 2008, Nick Piggin wrote:
> 
> I thought when there is no From in the body, then it defaults to the first
> Signed-off-by:

Nope. It defaults to the sender. The first signed-off is _usually_ the 
right choice, and you can use that as a sanity double-check, but I really 
avoid using it for authorship. We actually did that at one point, and it 
was reasonably often seriously screwed up and mis-attributed things.

[ It happened either because the first point in the chain had been some 
  trivial thing that got picked up without sign-off, or because the patch 
  had actually gone back-and-forth and the author signed off after testing 
  or improvements.

  The first case has been getting fairly rare as people get so used to 
  sign-offs, but it still happens. The second case has always been pretty 
  rare, but I'd still rather have it as a "sanity check" than a "blind 
  heuristic" ]

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
