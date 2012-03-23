Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 381F86B004D
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 15:11:22 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <042daf29-3991-4db6-bfe0-36ddc04c22f2@default>
Date: Fri, 23 Mar 2012 12:10:40 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] staging: ramster: unbreak my heart
References: <2d2c494d-64e3-4968-a406-a8ede7eb39bb@default>
 <20120323164848.GB22875@kroah.com>
In-Reply-To: <20120323164848.GB22875@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-mm@kvack.org

> From: Greg Kroah-Hartman [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [GIT PULL] staging: ramster: unbreak my heart
>=20
> On Fri, Mar 23, 2012 at 09:40:15AM -0700, Dan Magenheimer wrote:
> > Hey Greg  --
> >
> > The just-merged ramster staging driver was dependent on a cleanup patch=
 in
> > cleancache, so was marked CONFIG_BROKEN until that patch could be
> > merged.  That cleancache patch is now merged (and the correct SHA of th=
e
> > cleancache patch is 3167760f83899ccda312b9ad9306ec9e5dda06d4 rather tha=
n
> > the one shown in the comment removed in the patch below).
> >
> > So remove the CONFIG_BROKEN now and the comment that is no longer true.=
..
> >
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>=20
> Why do you say "GIT PULL" here, when this is just a single patch?  Odd.

Doh! Sorry, I was going to do a git tree, then realized a simple
patch would be better, then never went back to change the subject.
Sorry for the odd-ness.  Just a brain fart on my part.
=20
> I'll queue this up for sending to Linus after 3.4-rc1 is out, thanks.

Great, thanks!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
