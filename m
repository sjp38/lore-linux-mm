Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 356076B006C
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 13:07:43 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f0030f74-6c10-4127-beb9-96ef290ecf4c@default>
Date: Fri, 28 Oct 2011 09:37:25 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default
 CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
In-Reply-To: <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> You are changing core kernel code without ACKs from relevant
> maintainers. That's very unfortunate. Existing users certainly matter
> but that doesn't mean you get to merge code without maintainers even
> looking at it.
>=20
> So really, why don't you just use scripts/get_maintainer.pl and simply
> ask the relevant people for their ACK?

Actually I had done that before posting the patches and,
doing it now again, I *do* have many of the relevant people
on the ack list, and nearly all on the cc list of the
patch postings.  (I apologize that I see I missed you
on my list.) =20

I think every relevant maintainer has had the chance to
review and acknowledge but some have, for whatever reason,
chosen not to.=20

> Looking at your patches, there's no trace that anyone outside your own
> development team even looked at the patches.

Hmmm... I have reviews/acks from IBM, Fujitsu, and Citrix (and
a long list of documented Cc's) in the git comments, so I'm
not sure what you are seeing.

Ah, perhaps you are referring to the naming changes in the
cleancache hooks?  Akpm required me to rename various frontswap
hooks to use "invalidate" in the function name instead of
"flush".  I took the opportunity to rename the cleancache
hooks for consistency in this same patchset and this occurred
in only in the most recent version of the patchset.  It is true
that I didn't ask for Ack's from those maintainers, though
these changes would probably have gone through the trivial
patch monkey later anyway.

> Why do you feel that it's OK to ask Linus to pull them?

Frontswap is essentially the second half of the cleancache
patchset (or, more accurately, both are halves of the
transcendent memory patchset).  They are similar in that
the hooks in core MM code are fairly trivial and the
real value/functionality lies outside of the core kernel;
as a result core MM maintainers don't have much interest
I guess.

Linus personally merged cleancache for 3.0 (quoting from his
offlist email: "I've looked through it, and it seems simple
enough, with a pretty minimal support burden"); I was assuming
a similar path for frontswap.

I repeat that I'm not trying to subvert any process.  There
just doesn't seem to be much of a process in place for this kind
of a patchset, and I'm not letting silence or indifference
or "don't like it much" get in the way.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
