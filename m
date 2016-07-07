Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id B972C6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:35:26 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id f7so16424200vkb.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:35:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o186si3518208qkb.35.2016.07.07.09.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 09:35:26 -0700 (PDT)
Message-ID: <1467909317.13253.17.camel@redhat.com>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
From: Rik van Riel <riel@redhat.com>
Date: Thu, 07 Jul 2016 12:35:17 -0400
In-Reply-To: <1467843928-29351-2-git-send-email-keescook@chromium.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
	 <1467843928-29351-2-git-send-email-keescook@chromium.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-A8whchtqc1mx2jHwm8hg"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S.
 Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


--=-A8whchtqc1mx2jHwm8hg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-07-06 at 15:25 -0700, Kees Cook wrote:
>=C2=A0
> +	/* Allow kernel rodata region (if not marked as Reserved).
> */
> +	if (ptr >=3D (const void *)__start_rodata &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0end <=3D (const void *)__end_rodata)
> +		return NULL;
>=20
One comment here.

__check_object_size gets "to_user" as an argument.

It may make sense to pass that to check_heap_object, and
only allow copy_to_user from rodata, never copy_from_user,
since that section should be read only.

> +void __check_object_size(const void *ptr, unsigned long n, bool
> to_user)
> +{
>=C2=A0

--=20

All Rights Reversed.
--=-A8whchtqc1mx2jHwm8hg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXfoTFAAoJEM553pKExN6DSm8H/03wOEjAiET+COdQLbDEWApC
bEAOboYqibBhVsPZ557+S9y/UClhKOdBwA+nOKYw7ftj8gZZibkVBFbel7NV+s24
GHC3R1i1kGYK2YQflr2F2HGe1a8L1AWV7XuuxoBxqxP53zMrb9kAR3+vxRiz/bLc
nd4uQ1VhgPHOn1Ny6SSO6Ss6kM3wrsJw0+b2LS6erOUeA0IV7Wi01AMaRvLYiARR
yQEeIwn+lsENGCUMK/RGyiOJCW0m8FV6DrjtG3crG2CUtbjFnpMo225PrdOJMcBh
p5XyisW8AiGPrKm3ykxzNhPbOtP+2r8fVGgcUv7apHt+oORVNmVeEO1mP/yJATo=
=SHUM
-----END PGP SIGNATURE-----

--=-A8whchtqc1mx2jHwm8hg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
