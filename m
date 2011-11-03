Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 05E326B0069
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 10:59:48 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <7fcf24b1-95a0-4245-a0da-a4b2577ea485@default>
Date: Thu, 3 Nov 2011 07:59:17 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <20111031181651.GF3466@redhat.com> <1320142590.7701.64.camel@dabdike>
 <49255b17-02bb-4a4a-b85a-cd5a879beb98@default>
 <1320221686.3091.40.camel@dabdike>
 <2baa4c1a-1fe0-4395-a428-f30703e8c435@default
 86F488BC-2F99-4397-9467-A52AE1511FE0@mit.edu>
In-Reply-To: <86F488BC-2F99-4397-9467-A52AE1511FE0@mit.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Theodore Tso [mailto:tytso@mit.edu]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)

Hi Ted --

Thanks for your reply!
=20
> On Nov 2, 2011, at 4:08 PM, Dan Magenheimer wrote:
>=20
> > By "infinite" I am glibly describing any environment where the
> > data centre administrator positively knows the maximum working
> > set of every machine (physical or virtual) and can ensure in
> > advance that the physical RAM always exceeds that maximum
> > working set.  As you say, these machines need not be configured
> > with a swap device as they, by definition, will never swap.
> >
> > The point of tmem is to use RAM more efficiently by taking
> > advantage of all the unused RAM when the current working set
> > size is less than the maximum working set size.  This is very
> > common in many data centers too, especially virtualized.
>=20
> That doesn't match with my experience, especially with "cloud" deployment=
s, where in order to make the
> business plans work, the machines tend to be memory constrained, since yo=
u want to pack a large number
> of jobs/VM's onto a single machine, and high density memory is expensive =
and/or you are DIMM slot
> constrained.   Of course, if you are running multiple Java runtimes in ea=
ch guest OS (i.e., an J2EE
> server, and another Java VM for management, and yet another Java VM for t=
he backup manager, etc. ---
> really, I've seen cloud architectures that work that way), things get wor=
st even faster..

Hmmm... since your memory-constrained example is highly
similar to one I use in my presentations, I _think_ we are
in total agreement, but I am confused by "doesn't match
with my experience", or maybe you are countering James'
lean data centre example?

To clarify, for a multi-tenancy environment (such as
virtualization or RAMster), tmem enables the ability
to redistribute the constrained RAM resource, i.e.
"steal from the rich and give to the poor," which is
otherwise very difficult because each kernel is a
memory hog.  Frontswap's role is really to announce
"I'm overconstrained and am about to swap to disk,
which would be embarrassing for my performance...
can someone hold this swap page for me, please?"

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
