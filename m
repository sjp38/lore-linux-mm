Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06593
	for <linux-mm@kvack.org>; Sun, 30 May 1999 13:47:36 -0400
Date: Sun, 30 May 1999 10:47:06 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] cache large files in the page cache
In-Reply-To: <m1675a4gv7.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.95.990530104226.18638J-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 30 May 1999, Eric W. Biederman wrote:
> 
> LT> Indeed. An dI would suggest that the shift be limited to at most 9 anyway:
> LT> right now I applied the part that disallows non-page-aligned offsets, but
> LT> I think that we may in the future allow anonymous mappings again at finer
> LT> granularity (somebody made a really good argument about wine for this).
> 
> I'd love to hear the argument.   Something that would negate the disadvantage
> of ntuple buffering, and the need for reverse page maps, and isn't portable.

Wine.

Mapping windows binaries in a Linux address space.

Portability is a non-issue: this would only work on a 386, and only on
Linux anyway (MAYBE on other architectures Wine supports, but that's their
problem). 

Windows binaries are _not_ nicely aligned like the Linux ones. They are
often 512-byte aligned.

Yes, we can read them in. That is slow as hell, and doesn't allow sharing. 
Bad. 

> Well, currectly supporting non-aligned mappings needs more than just a
> few extra bits.  The code to update all mappings on write, and the
> ability to ensure that a given byte is only faulted in for a single
> offset at a time.   (Admittedly if everything is a read mapping you
> can be a smidge more lax).

We would not guarantee write coherency for anything but the page-aligned
case. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
