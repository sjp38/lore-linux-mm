Date: Wed, 28 Jul 1999 11:46:43 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: active_mm & SMP & TLB flush: possible bug
In-Reply-To: <379EF7D0.375C78A4@colorfullife.com>
Message-ID: <Pine.LNX.3.96.990728114443.27907A-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: masp0008@stud.uni-sb.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jul 1999, Manfred Spraul wrote:

> if these 2 CPU switch their roles, then we use an outdates
> TLB cache.

You're right, thankfully it's fixed in 2.3.12-8 (meaning that my dual
finally stops SIGSEGVing random processes).

> BTW, where can I find more details about the active_mm implementation?
> specifically, I'd like to know why active_mm was added to
> "struct task_struct".
> >From my first impression, it's a CPU specific information
> (every CPU has exactly one active_mm, threads which are not running have
> no
> active_mm), so I'd have used a global array[NR_CPUS].

That soulds like a good idea -- care to offer a patch? =)

		-ben

--
Hi!  I'm Signature Virus 99!  Copy me into your .signature and join the fun!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
