Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0F2C8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 18:41:13 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id o6so1303409wmf.0
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:41:13 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id y71si26679705wme.122.2019.01.17.15.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 15:41:12 -0800 (PST)
Date: Fri, 18 Jan 2019 00:41:11 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 14/17] mm: Make hibernate handle unmapped pages
Message-ID: <20190117234111.GA27661@amd>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-15-rick.p.edgecombe@intel.com>
 <20190117093950.GA17930@amd>
 <b224d88d91a5c45c44e176ea06dea558a8939ccf.camel@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Content-Disposition: inline
In-Reply-To: <b224d88d91a5c45c44e176ea06dea558a8939ccf.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com" <linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > > For architectures with CONFIG_ARCH_HAS_SET_ALIAS, pages can be unmapp=
ed
> > > briefly on the directmap, even when CONFIG_DEBUG_PAGEALLOC is not
> > > configured.
> > > So this changes kernel_map_pages and kernel_page_present to be define=
d when
> > > CONFIG_ARCH_HAS_SET_ALIAS is defined as well. It also changes places
> > > (page_alloc.c) where those functions are assumed to only be implement=
ed when
> > > CONFIG_DEBUG_PAGEALLOC is defined.
> >=20
> > Which architectures are that?
> >=20
> > Should this be merged to the patch where HAS_SET_ALIAS is introduced? We
> > don't want broken hibernation in between....
> Thanks for taking a look. It was added for x86 for patch 13 in this patch=
set and
> there was interest expressed for adding for arm64. If you didn't get the =
whole
> set and want to see let me know and I can send it.

I googled in in the meantime.

Anyway, if something is broken between patch 13 and 14, then they
should be same patch.

> > > -#ifdef CONFIG_DEBUG_PAGEALLOC
> > >  extern bool _debug_pagealloc_enabled;
> > > -extern void __kernel_map_pages(struct page *page, int numpages, int
> > > enable);
> > > =20
> > >  static inline bool debug_pagealloc_enabled(void)
> > >  {
> > > -	return _debug_pagealloc_enabled;
> > > +	return IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) && _debug_pagealloc_enabl=
ed;
> > >  }
> >=20
> > This will break build AFAICT. _debug_pagealloc_enabled variable does
> > not exist in !CONFIG_DEBUG_PAGEALLOC case.
> >=20
> > 									Pavel
> After adding in the CONFIG_ARCH_HAS_SET_ALIAS condition to the ifdefs in =
this
> area it looked a little hard to read to me, so I moved debug_pagealloc_en=
abled
> and extern bool _debug_pagealloc_enabled outside to make it easier. I thi=
nk you
> are right, the actual non-extern variable can not be there, but the refer=
ence
> here gets optimized out in that case.
>=20
> Just double checked and it builds for both CONFIG_DEBUG_PAGEALLOC=3Dn and
> CONFIG_DEBUG_PAGEALLOC=3Dy for me.

Ok.

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlxBEpcACgkQMOfwapXb+vJtzQCgvAwnrEXHgIY02PxK4qHmnWt+
IrEAoJ0xu9GgDa1q1fjYTxxvffORlpYi
=atbx
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
