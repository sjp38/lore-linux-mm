Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id AF5C56B005A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 11:25:40 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <041cb4ce-48ae-4600-9f11-d722bc03b9cc@default>
Date: Mon, 6 Aug 2012 08:24:25 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
 <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
 <20120731155843.GP4789@phenom.dumpdata.com> <20120731161916.GA4941@kroah.com>
 <20120731175142.GE29533@phenom.dumpdata.com> <20120806003816.GA11375@bbox>
In-Reply-To: <20120806003816.GA11375@bbox>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

> > I think we (that is me, Seth, Minchan, Dan) need to talk to have a good
> > understanding of what each of us thinks are fixups.
> >
> > Would Monday Aug 6th at 1pm EST on irc.freenode.net channel #zcache wor=
k
> > for people?
>=20
> 1pm EST is 2am KST(Korea Standard Time) so it's not good for me. :)
> I know it's hard to adjust my time for yours so let you talk without
> me. Instead, I will write it down my requirement. It's very simple and
> trivial.
>=20
> 1) Please don't add any new feature like replace zsmalloc with zbud.
>    It's totally untested so it needs more time for stable POV bug,
>    or performance/fragementation.
>=20
> 2) Factor out common code between zcache and ramster. It should be just
>    clean up code and should not change current behavior.
>=20
> 3) Add lots of comment to public functions
>=20
> 4) make function/varabiel names more clearly.
>=20
> They are necessary for promotion and after promotion,
> let's talk about new great features.

Hi Minchan --

I hope you had a great vacation!

Since we won't be able to discuss this by phone/irc, I guess I
need to reply here.

Let me first restate my opinion as author of zcache.

The zcache in staging is really a "demo" version.  It was written 21
months ago (and went into staging 16 months ago) primarily to show,
at Andrew Morton's suggestion, that frontswap and cleancache had value
in a normal standalone kernel (i.e. virtualization not required).  When
posted in early 2011 zcache was known to have some fundamental flaws in the=
 design...
that's why it went into "staging".  The "demo" version in staging still has
those flaws and the change from xvmalloc to zsmalloc makes one of those fla=
ws
worse.  These design flaws are now fixed in the new code base I posted last
week AND the new code base has improved factoring, comments and the code is
properly re-merged with the zcache "fork" in ramster.

We are not talking about new "features"...  I have tried to back out the
new features from the new code base already posted and will post them separ=
ately.

So I think we have four choices:

A) Try to promote zcache as is.  (Seth's proposal)
B) Clean up zcache with no new functionality. (Minchan's proposal above)
C) New code base (in mm/tmem/) after review. (Dan's proposal)
D) New code base but retrofit as a series of patches (Konrad's suggestion)

Minchan, if we go with your proposal (B) are you volunteering
to do the work?  And if you do, doesn't it have the same issue
that it is also totally untested?  And, since (B) doesn't solve the
fundamental design issues, are you volunteering to fix those next?
And, in the meantime, doesn't this mean we have THREE versions
of zcache?

IMHO, the fastest way to get the best zcache into the kernel and
to distros and users is to throw away the "demo" version, move forward
to a new solid well-designed zcache code base, and work together to
build on it.  There's still a lot to do so I hope we can work together.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
