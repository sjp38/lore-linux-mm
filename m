Date: Fri, 20 Aug 1999 11:25:27 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <37BD0559.99C5E320@mandrakesoft.com>
Message-ID: <Pine.LNX.4.10.9908201120180.1546-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thierry Vignaud <tvignaud@mandrakesoft.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, x-linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 20 Aug 1999, Thierry Vignaud wrote:
>
> Yes, but we do can use 24:32 referencse (as

Nope.

That's pure Intel propaganda, and has absolutely no basis in reality.

There's a 13:32 bit address space, with the 13 bits coming from the
segment registers. True.

However, that does NOT give you 45 bits of addressing, however much Intel
tried to claim that in early literature. The 13:32 address is mapped onto
a plain linear 32-bit address space, and that's all it gives you.

[ In theory, you can play games with the present bit in the segments to
  make it appear like more, but in practice that is basically useless too,
  don't even bother mentioning it ]

You can make the 36 physical bits available to software the same way
people used to do expansion memory on a 286 - by having a window and
having software change that window. Some databases would be happy with
that. But I much prefer just letting processes have their 3GB worth of
address space, and being able to map in the occasional big page when
really needed. 

Or, actually, I'd much prefer a sane architecture that doesn't continually
try to reinvent the bad idea of memory windows.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
