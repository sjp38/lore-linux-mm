Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B64D96B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 17:34:57 -0500 (EST)
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
In-Reply-To: Your message of "Fri, 28 Oct 2011 16:52:28 EDT."
             <20139.5644.583790.903531@quad.stoffel.home>
From: Valdis.Kletnieks@vt.edu
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default> <75efb251-7a5e-4aca-91e2-f85627090363@default> <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy> <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com> <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default> <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com> <20111028163053.GC1319@redhat.com> <3982e04f-8607-4f0a-b855-2e7f31aaa6f7@default>
            <20139.5644.583790.903531@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1320618774_135101P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sun, 06 Nov 2011 17:32:54 -0500
Message-ID: <201529.1320618774@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

--==_Exmh_1320618774_135101P
Content-Type: text/plain; charset=us-ascii

On Fri, 28 Oct 2011 16:52:28 EDT, John Stoffel said:
> Dan> "WHY" this is such a good idea is the same as WHY it is useful to
> Dan> add RAM to your systems. 
>
> So why would I use this instead of increasing the physical RAM?

You're welcome to buy me a new laptop that has a third DIMM slot. :)

There's a lot of people running hardware that already has the max amount of
supported RAM, and who for budget or legacy-support reasons can't easily do a
forklift upgrade to a new machine.

> if I've got a large system which cannot physically use any more
> memory, then it might be worth my while to use TMEM to get more
> performance out of this expensive hardware.

It's not always a large system....

--==_Exmh_1320618774_135101P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOtwsWcC3lWbTT17ARAlvfAKCoKX68t1pDd8M1xDoZuSpVYUljjACfRYID
7BmJgF1WCyqaQVF50mbeXUg=
=pNIL
-----END PGP SIGNATURE-----

--==_Exmh_1320618774_135101P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
