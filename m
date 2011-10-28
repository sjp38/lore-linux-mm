Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BD4736B0069
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 13:07:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b86860d2-3aac-4edd-b460-bd95cb1103e6@default>
Date: Fri, 28 Oct 2011 10:07:12 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default>
 <CAOJsxLEE-qf9me1SAZLFiEVhHVnDh7BDrSx1+abe9R4mfkhD=g@mail.gmail.com
 20111028163053.GC1319@redhat.com>
In-Reply-To: <20111028163053.GC1319@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>, Pekka Enberg <penberg@kernel.org>
Cc: Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>


> From: Johannes Weiner [mailto:jweiner@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On Fri, Oct 28, 2011 at 06:36:03PM +0300, Pekka Enberg wrote:
> > On Fri, Oct 28, 2011 at 6:21 PM, Dan Magenheimer
> > <dan.magenheimer@oracle.com> wrote:
> > Looking at your patches, there's no trace that anyone outside your own
> > development team even looked at the patches. Why do you feel that it's
> > OK to ask Linus to pull them?
>=20
> People did look at it.
>=20
> In my case, the handwavy benefits did not convince me.  The handwavy
> 'this is useful' from just more people of the same company does not
> help, either.
>=20
> I want to see a usecase that tangibly gains from this, not just more
> marketing material.  Then we can talk about boring infrastructure and
> adding hooks to the VM.
>=20
> Convincing the development community of the problem you are trying to
> solve is the undocumented part of the process you fail to follow.

Hi Johannes --

First, there are several companies and several unaffiliated kernel
developers contributing here, building on top of frontswap.  I happen
to be spearheading it, and my company is backing me up.  (It
might be more appropriate to note that much of the resistance comes
from people of your company... but please let's keep our open-source
developer hats on and have a technical discussion rather than one
which pleases our respective corporate overlords.)

Second, have you read http://lwn.net/Articles/454795/ ?
If not, please do.  If yes, please explain what you don't
see as convincing or tangible or documented.  All of this
exists today as working publicly available code... it's
not marketing material.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
