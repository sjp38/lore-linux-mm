Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id F05706B0044
	for <linux-mm@kvack.org>; Thu,  3 May 2012 17:12:06 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6436426b-5c46-4457-9d78-6b0af5ce4a3b@default>
Date: Thu, 3 May 2012 14:11:47 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] drivers: staging: zcache: fix Kconfig crypto dependency
References: <1335231230-29344-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <4F9B3BEB.1040805@xenotime.net>
In-Reply-To: <4F9B3BEB.1040805@xenotime.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Autif Khan <autif.mlist@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Randy Dunlap <rdunlap@xenotime.net>, Seth Jennings <sjenning@linux.vnet.ibm.com>

> From: Randy Dunlap [mailto:rdunlap@xenotime.net]
> Sent: Friday, April 27, 2012 6:38 PM
> To: Seth Jennings
> Cc: Greg Kroah-Hartman; devel@driverdev.osuosl.org; Dan Magenheimer; Auti=
f Khan; Konrad Rzeszutek
> Wilk; linux-kernel@vger.kernel.org; linux-mm@kvack.org; Robert Jennings; =
Nitin Gupta
> Subject: Re: [PATCH] drivers: staging: zcache: fix Kconfig crypto depende=
ncy
>=20
> On 04/23/2012 06:33 PM, Seth Jennings wrote:
>=20
> > ZCACHE is a boolean in the Kconfig.  When selected, it
> > should require that CRYPTO be builtin (=3Dy).
> >
> > Currently, ZCACHE=3Dy and CRYPTO=3Dm is a valid configuration
> > when it should not be.
> >
> > This patch changes the zcache Kconfig to enforce this
> > dependency.
> >
> > Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>=20
>=20
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Not sure if you need my approval, but I just in case you are waiting
for it:

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

> > ---
> >  drivers/staging/zcache/Kconfig |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kc=
onfig
> > index 3ed2c8f..7048e01 100644
> > --- a/drivers/staging/zcache/Kconfig
> > +++ b/drivers/staging/zcache/Kconfig
> > @@ -2,7 +2,7 @@ config ZCACHE
> >  =09bool "Dynamic compression of swap pages and clean pagecache pages"
> >  =09# X86 dependency is because zsmalloc uses non-portable pte/tlb
> >  =09# functions
> > -=09depends on (CLEANCACHE || FRONTSWAP) && CRYPTO && X86
> > +=09depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=3Dy && X86
> >  =09select ZSMALLOC
> >  =09select CRYPTO_LZO
> >  =09default n
>=20
>=20
>=20
> --
> ~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
