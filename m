Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2AC6B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 17:33:07 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <d5104e62-0783-4af2-8892-d5a8ecc123a4@default>
Date: Tue, 1 Nov 2011 14:32:48 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
 <20111028163053.GC1319@redhat.com>
 <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
 <20138.62532.493295.522948@quad.stoffel.home>
 <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
 <1320048767.8283.13.camel@dabdike>
 <424e9e3a-670d-4835-914f-83e99a11991a@default>
 <1320142403.7701.62.camel@dabdike>
 <bb0996fb-9b83-4de2-a1e4-d9c810c4b48a@default
 1320173294.15403.109.camel@nimitz>
In-Reply-To: <1320173294.15403.109.camel@nimitz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, John Stoffel <john@stoffel.org>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Jonathan Corbet <corbet@lwn.net>

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On Tue, 2011-11-01 at 11:10 -0700, Dan Magenheimer wrote:
> > Case A) CONFIG_FRONTSWAP=3Dn
> > Case B) CONFIG_FRONTSWAP=3Dy and no tmem backend registers
> > Case C) CONFIG_FRONTSWAP=3Dy and a tmem backend DOES register
> ...
> > The point is that only Case C has possible interactions
> > so Case A and Case B end-users and kernel developers need
> > not worry about the maintenance.
>=20
> I'm personally evaluating this as if all the distributions would turn it
> on.  I'm evaluating as if every one of my employer's systems ships with
> it and as if it is =3Dy my laptop.  Basically, I'm evaluating A/B/C and
> only looking at the worst-case maintenance cost (C).  In other words,
> I'm ignoring A/B and assuming wide use.

Good.  Me too.  I was just saying that the-company-that-must-not-
be-named (from which most of the non-technical objections are=20
coming), can choose A or B as they wish without any impact
to their developers or users.
=20
> I'm curious where you expect to see the code get turned on and used
> since we might be looking at this from different angles.

I think we are on the same page.  Oracle is turning it on (case B)
in the default UEK kernel, for which the Beta git tree is published.
Corporate policy keeps me from saying anything in detail about
pre-released products, but you saw that our Oracle VM manager
responded to this thread, so I'll leave that to your imagination.

I think we agreed offlist that zcache is not ready for prime-time
and a good measure of when it _will_ be ready is when it is
promoted out of staging.  I'm really hoping you guys at IBM
will drive that (and am willing to get out of the way if you
prefer).

There's a lot of interest in Oracle in RAMster (which I personally
think is very sexy), but I haven't been able to make forward progress
in nearly three months now due to other fires and commitments. :-(

So are we on the same page?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
