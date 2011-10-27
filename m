Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B3F266B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 18:21:49 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <baba3ba5-11d1-4137-a4be-ca4381bf192b@default>
Date: Thu, 27 Oct 2011 15:21:39 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <alpine.DEB.2.00.1110271318220.7639@chino.kir.corp.google.com20111027211157.GA1199@infradead.org>
 <75efb251-7a5e-4aca-91e2-f85627090363@default
 20111027215243.GA31644@infradead.org>
In-Reply-To: <20111027215243.GA31644@infradead.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

> From: Christoph Hellwig [mailto:hch@infradead.org]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On Thu, Oct 27, 2011 at 02:49:31PM -0700, Dan Magenheimer wrote:
> > If Linux truly subscribes to the "code rules" mantra, no core
> > VM developer has proposed anything -- even a design, let alone
> > working code -- that comes close to providing the functionality
> > and flexibility that frontswap (and cleancache) provides, and
> > frontswap provides it with a very VERY small impact on existing
> > kernel code AND has been posted and working for 2+ years.
> > (And during that 2+ years, excellent feedback has improved the
> > "kernel-ness" of the code, but NONE of the core frontswap
> > design/hooks have changed... because frontswap _just works_!)
>=20
> It might work for whatever defintion of work, but you certainly couldn't
> convince anyone that matters that it's actually sexy and we'd actually
> need it.  Only actually working on Xen of course doesn't help.
>=20
> In the end it's a bunch of really ugly hooks over core code, without
> a clear defintion of how they work or a killer use case.

Hi Christoph --

You might find it useful to read the whole base email and/or
the lwn article referenced.  Frontswap and cleancache
have now gone far beyond X-e-n** and even beyond virtualization.
That's why my talk at Linuxcon was titled "Transcendent Memory:
Not Just for Virtualization Anymore".  (And I stated at
that talk that I have personally not written a line of
X-e-n code in over a year now.)  The same frontswap hooks
_just work_ for zcache, RAMster and (soon) KVM too...
and there's more uses coming.  Those that take the time
to understand its use model DO find frontswap useful.

Is "sexy" or "killer use case" a requirement for Linus
to merge code now?  If so, he can plan to spend a lot
more time diving as I'll bet there isn't much code that
measures up.

Thanks,
Dan

** /me suspects that Christoph has a /dev/null filter for
email containing that word so has cleverly spelled it out
to defeat that filter :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
