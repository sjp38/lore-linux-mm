Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D316D6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 17:27:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 78so3136266wmb.15
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 14:27:43 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id 46si3494078wrw.433.2017.10.23.14.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 14:27:42 -0700 (PDT)
Date: Mon, 23 Oct 2017 23:27:41 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
Message-ID: <20171023212741.GA12782@amd>
References: <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd>
 <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <72c93a69-610f-027e-c028-379b97b6f388@intel.com>
 <20171002084131.GA24414@amd>
 <CACRpkdbatrt0Uxf8653iiV-OKkgcc0Ziog_L4oDVTJVNqtNN0Q@mail.gmail.com>
 <20171002130353.GA25433@amd>
 <184b3552-851c-7015-dd80-76f6eebc33cc@intel.com>
 <20171023093109.GI32228@amd>
 <CACRpkdaa6qq91+dQ43EZDvDefbM3tjwLX5e+nNZouwXM0xJ=4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
In-Reply-To: <CACRpkdaa6qq91+dQ43EZDvDefbM3tjwLX5e+nNZouwXM0xJ=4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: Adrian Hunter <adrian.hunter@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2017-10-23 14:16:40, Linus Walleij wrote:
> On Mon, Oct 23, 2017 at 11:31 AM, Pavel Machek <pavel@ucw.cz> wrote:
>=20
> >> > Thinkpad X220... how do I tell if I was using them? I believe so,
> >> > because I uncovered bug in them before.
> >>
> >> You are certainly using bounce buffers.  What does lspci -knn show?
> >
> > Here is the output:
> > 0d:00.0 System peripheral [0880]: Ricoh Co Ltd PCIe SDXC/MMC Host Contr=
oller [1180:e823] (rev 07)
> >         Subsystem: Lenovo Device [17aa:21da]
> >         Kernel driver in use: sdhci-pci
>=20
> So that is a Ricoh driver, one of the few that was supposed to benefit
> from bounce buffers.
>=20
> Except that if you actually turned it on:
> > [10994.302196] kworker/2:1: page allocation failure: order:4,
> so it doesn't have enough memory to use these bounce buffers
> anyway.

Well, look at archives: driver failed completely when allocation failed.=20

> I'm now feel it was the right thing to delete them.

Which means I may have been geting benefit -- when it worked. I
believe solution is to allocate at driver probing time.

(OTOH ... SPI is slow compared to rest of the system, right? Where
does the benefit come from?)

									Pavel



--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnuXs0ACgkQMOfwapXb+vIYcwCeI58Zgqs30Jwo2akGea9juTmi
eccAn1EdAgek8vxV8IKC9nYpZdbzdage
=0tO5
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
