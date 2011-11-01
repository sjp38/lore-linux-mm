Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB3A6B006E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 14:21:35 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <49255b17-02bb-4a4a-b85a-cd5a879beb98@default>
Date: Tue, 1 Nov 2011 11:21:20 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <20111031181651.GF3466@redhat.com 1320142590.7701.64.camel@dabdike>
In-Reply-To: <1320142590.7701.64.camel@dabdike>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> Actually, I think there's an unexpressed fifth requirement:
>=20
> 5. The optimised use case should be for non-paging situations.

Not quite sure what you mean here (especially for frontswap)...
=20
> The problem here is that almost every data centre person tries very hard
> to make sure their systems never tip into the swap zone.  A lot of
> hosting datacentres use tons of cgroup controllers for this and
> deliberately never configure swap which makes transcendent memory
> useless to them under the current API.  I'm not sure this is fixable,

I can't speak for cgroups, but the generic "state-of-the-art"
that you describe is a big part of what frontswap DOES try
to fix, or at least ameliorate.  Tipping "into the swap zone"
is currently very bad.  Very very bad.  Frontswap doesn't
"solve" swapping, but it is the foundation for some of the
first things in a long time that aren't just "add more RAM."

> but it's the reason why a large swathe of users would never be
> interested in the patches, because they by design never operate in the
> region transcended memory is currently looking to address.

It's true, those that are memory-rich and can spend nearly
infinite amounts on more RAM (and on high-end platforms that
can expand to hold massive amounts of RAM) are not tmem's
target audience.

> This isn't an inherent design flaw, but it does ask the question "is
> your design scope too narrow?"

Considering all the hazing that I've gone through to get
this far, you think I should _expand_ my design scope?!? :-)
Thanks, I guess I'll pass. :-)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
