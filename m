Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD8BC8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 04:39:53 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id p12so4560346wrt.17
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 01:39:53 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id u14si25858787wmu.50.2019.01.17.01.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 01:39:52 -0800 (PST)
Date: Thu, 17 Jan 2019 10:39:50 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 14/17] mm: Make hibernate handle unmapped pages
Message-ID: <20190117093950.GA17930@amd>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-15-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jRHKVT23PllUwdXP"
Content-Disposition: inline
In-Reply-To: <20190117003259.23141-15-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> For architectures with CONFIG_ARCH_HAS_SET_ALIAS, pages can be unmapped
> briefly on the directmap, even when CONFIG_DEBUG_PAGEALLOC is not configu=
red.
> So this changes kernel_map_pages and kernel_page_present to be defined wh=
en
> CONFIG_ARCH_HAS_SET_ALIAS is defined as well. It also changes places
> (page_alloc.c) where those functions are assumed to only be implemented w=
hen
> CONFIG_DEBUG_PAGEALLOC is defined.

Which architectures are that?

Should this be merged to the patch where HAS_SET_ALIAS is introduced? We
don't want broken hibernation in between....


> -#ifdef CONFIG_DEBUG_PAGEALLOC
>  extern bool _debug_pagealloc_enabled;
> -extern void __kernel_map_pages(struct page *page, int numpages, int enab=
le);
> =20
>  static inline bool debug_pagealloc_enabled(void)
>  {
> -	return _debug_pagealloc_enabled;
> +	return IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) && _debug_pagealloc_enabled;
>  }

This will break build AFAICT. _debug_pagealloc_enabled variable does
not exist in !CONFIG_DEBUG_PAGEALLOC case.

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--jRHKVT23PllUwdXP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlxATWYACgkQMOfwapXb+vLhEwCfboaaFJileFziF32t0acTiuuz
dewAn0oneo6RWHmnu+B3dnprdMW4dCOy
=4kpb
-----END PGP SIGNATURE-----

--jRHKVT23PllUwdXP--
