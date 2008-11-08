Date: Fri, 7 Nov 2008 21:13:38 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 0/9] vmalloc fixes and improvements
In-Reply-To: <20081108021512.686515000@suse.de>
Message-ID: <alpine.LFD.2.00.0811072109550.3468@nehalem.linux-foundation.org>
References: <20081108021512.686515000@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, glommer@redhat.com, rjw@sisk.pl
List-ID: <linux-mm.kvack.org>


On Sat, 8 Nov 2008, npiggin@suse.de wrote:
> 
> The following patches are a set of fixes and improvements for the vmap
> layer.

They seem seriously buggered.

Patches that seem to be authorted by others (judging by sign-off) have no 
such attribution. And because you apparently use some sh*t-for-emailer, 
the patches that _are_ yours are missing your name, because it just says

	From: npiggin@suse.de

without any "Nick Piggin" there.

I'd suggest fixing your emailer scripts regardless, but a "From: " at the 
top of the body would fix both the attribution to others, and give you a 
name too.

PLEASE. Missing authorship attribution is seriously screwed up. Don't do 
it.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
