Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA24425
	for <linux-mm@kvack.org>; Sat, 25 Apr 1998 01:33:00 -0400
Subject: Re: Fixing private mappings
References: <Pine.LNX.3.95.980423105842.15346A-100000@as200.spellcast.com>
	<m1g1j4nqll.fsf@flinx.npwt.net>
	<199804242037.VAA01182@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 25 Apr 1998 00:30:53 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Fri, 24 Apr 1998 21:37:45 +0100
Message-ID: <m1hg3imprm.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> Hi,
ST> On 23 Apr 1998 17:03:02 -0500, ebiederm+eric@npwt.net (Eric
ST> W. Biederman) said:

ST> No --- in the context of a MAP_PRIVATE mapping, only in-memory writes to
ST> the privately mapped virtual address space count as write references.  

Got it. 
I still like the semantics I defined, but if they aren't defined as
map_private I won't worry about it for the present.

Sometime it might be worth it/fun implementing a MAP_SNAPSHOT, but I
won't worry about that for the present.

ST> Yep, but we are not required to support non-page-aligned maps at all, so
ST> hacking it for special read-only cases is no big deal.  Doing a search
ST> for all overlapping mapped pages would be far too slow.

I think in the general case I could implement it without overhead and
in the common a.out case within a factor of 2, and in the worst case
within a factor of 4 (assuming a restriction of 1k alignment).  And
this is primarly memcpy cost there should be no need for extra disk
i/o.

The scheme I'm playing with using will share the same case as extra
huge file I/O (> 16TB), and in the common case should perform
identically to what we have now.

Thanks for setting me straight.  It hadn't been my intention to play
with mmap until I found this really weird use of that mmap makes of
the page_cache, so I really wasn't prepared for that one.

Eric
