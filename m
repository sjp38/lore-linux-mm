Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B9F306B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 13:14:47 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <592e2b8c-d610-49e1-b9b7-71ab6ef680aa@default>
Date: Thu, 6 Sep 2012 10:13:58 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [patch] staging: ramster: fix range checks in
 zcache_autocreate_pool()
References: <20120906124020.GA28946@elgon.mountain>
 <20120906162515.GA423@kroah.com>
 <a8f8ff87-ca0e-4a16-adc5-a9af8cbb5026@default>
In-Reply-To: <a8f8ff87-ca0e-4a16-adc5-a9af8cbb5026@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>

> From: Dan Magenheimer
> Subject: RE: [patch] staging: ramster: fix range checks in zcache_autocre=
ate_pool()
>=20
> > From: Greg Kroah-Hartman [mailto:gregkh@linuxfoundation.org]
> > Subject: Re: [patch] staging: ramster: fix range checks in zcache_autoc=
reate_pool()
> >
> > On Thu, Sep 06, 2012 at 03:40:20PM +0300, Dan Carpenter wrote:
> > > If "pool_id" is negative then it leads to a read before the start of =
the
> > > array.  If "cli_id" is out of bounds then it leads to a NULL derefere=
nce
> > > of "cli".  GCC would have warned about that bug except that we
> > > initialized the warning message away.
> > >
> > > Also it's better to put the parameter names into the function
> > > declaration in the .h file.  It serves as a kind of documentation.
> > >
> > > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > > ---
> > > BTW, This file has a ton of GCC warnings.  This function returns -1
> > > on error which is a nonsense return code but the return value is not
> > > checked anyway.  *Grumble*.
> >
> > I agree, it's very messy.  Dan Magenheimer should have known better, an=
d
> > he better be sending me a patch soon to remove these warnings (hint...)
>=20
> On its way soon.

> > > BTW, This file has a ton of GCC warnings.

Submitted (with typo in kernel-janitors address)... but I also just
realized from previous feedback on a much earlier thread...

I use a stable RHEL6-ish system for devel/test with gcc-4.4.5,
and newer gcc's may report more warnings than I see or have fixed.

If there is now a required newer gcc version for patch submittals,
please let me know.

(However, I will be away from email for a few days, so apologies in
advance if I can't respond immediately.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
