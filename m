Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E95506B0068
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 12:33:44 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a8f8ff87-ca0e-4a16-adc5-a9af8cbb5026@default>
Date: Thu, 6 Sep 2012 09:32:54 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [patch] staging: ramster: fix range checks in
 zcache_autocreate_pool()
References: <20120906124020.GA28946@elgon.mountain>
 <20120906162515.GA423@kroah.com>
In-Reply-To: <20120906162515.GA423@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>

> From: Greg Kroah-Hartman [mailto:gregkh@linuxfoundation.org]
> Subject: Re: [patch] staging: ramster: fix range checks in zcache_autocre=
ate_pool()
>=20
> On Thu, Sep 06, 2012 at 03:40:20PM +0300, Dan Carpenter wrote:
> > If "pool_id" is negative then it leads to a read before the start of th=
e
> > array.  If "cli_id" is out of bounds then it leads to a NULL dereferenc=
e
> > of "cli".  GCC would have warned about that bug except that we
> > initialized the warning message away.
> >
> > Also it's better to put the parameter names into the function
> > declaration in the .h file.  It serves as a kind of documentation.
> >
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > BTW, This file has a ton of GCC warnings.  This function returns -1
> > on error which is a nonsense return code but the return value is not
> > checked anyway.  *Grumble*.
>=20
> I agree, it's very messy.  Dan Magenheimer should have known better, and
> he better be sending me a patch soon to remove these warnings (hint...)

On its way soon.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
