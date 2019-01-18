Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36A178E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 03:16:12 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id m4so6419866wrr.4
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 00:16:12 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id j142si26111916wmj.106.2019.01.18.00.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 00:16:10 -0800 (PST)
Date: Fri, 18 Jan 2019 09:16:09 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 14/17] mm: Make hibernate handle unmapped pages
Message-ID: <20190118081609.GA10712@amd>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-15-rick.p.edgecombe@intel.com>
 <20190117093950.GA17930@amd>
 <b224d88d91a5c45c44e176ea06dea558a8939ccf.camel@intel.com>
 <20190117234111.GA27661@amd>
 <3c12f9b3328ee32d04a6ed3990fdf0cd3cb27532.camel@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline
In-Reply-To: <3c12f9b3328ee32d04a6ed3990fdf0cd3cb27532.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com" <linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2019-01-17 23:48:30, Edgecombe, Rick P wrote:
> On Fri, 2019-01-18 at 00:41 +0100, Pavel Machek wrote:
> > Hi!
> >=20
> > > > > For architectures with CONFIG_ARCH_HAS_SET_ALIAS, pages can be un=
mapped
> > > > > briefly on the directmap, even when CONFIG_DEBUG_PAGEALLOC is not
> > > > > configured.
> > > > > So this changes kernel_map_pages and kernel_page_present to be de=
fined
> > > > > when
> > > > > CONFIG_ARCH_HAS_SET_ALIAS is defined as well. It also changes pla=
ces
> > > > > (page_alloc.c) where those functions are assumed to only be imple=
mented
> > > > > when
> > > > > CONFIG_DEBUG_PAGEALLOC is defined.
> > > >=20
> > > > Which architectures are that?
> > > >=20
> > > > Should this be merged to the patch where HAS_SET_ALIAS is introduce=
d? We
> > > > don't want broken hibernation in between....
> > >=20
> > > Thanks for taking a look. It was added for x86 for patch 13 in this p=
atchset
> > > and
> > > there was interest expressed for adding for arm64. If you didn't get =
the
> > > whole
> > > set and want to see let me know and I can send it.
> >=20
> > I googled in in the meantime.
> >=20
> > Anyway, if something is broken between patch 13 and 14, then they
> > should be same patch.
> Great. It should be ok because the new functions are not used anywhere un=
til
> after this patch.

Ok, that makes sense.

Acked-by: Pavel Machek <pavel@ucw.cz>
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlxBi0kACgkQMOfwapXb+vKV/QCdFLyEDo+ouJctFO52d/hTAxAP
oF0AoIpc7mH97WDF7SfB+pCr3f0ec1vR
=niXa
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--
