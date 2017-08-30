Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9255F6B02B4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 14:55:09 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m62so10050246qki.9
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:55:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 81si728647qkw.3.2017.08.30.11.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 11:55:09 -0700 (PDT)
Message-ID: <1504119305.26846.78.camel@redhat.com>
Subject: Re: [kernel-hardening] [PATCH v2 27/30] x86: Implement
 thread_struct whitelist for hardened usercopy
From: Rik van Riel <riel@redhat.com>
Date: Wed, 30 Aug 2017 14:55:05 -0400
In-Reply-To: <1503956111-36652-28-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
	 <1503956111-36652-28-git-send-email-keescook@chromium.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-GJL8Jf6wR815Diotm9MM"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Mathias Krause <minipli@googlemail.com>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>


--=-GJL8Jf6wR815Diotm9MM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-08-28 at 14:35 -0700, Kees Cook wrote:
> This whitelists the FPU register state portion of the thread_struct
> for
> copying to userspace, instead of the default entire struct.
>=20
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: Borislav Petkov <bp@suse.de>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Mathias Krause <minipli@googlemail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> =C2=A0arch/x86/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 1 +
> =C2=A0arch/x86/include/asm/processor.h | 8 ++++++++
> =C2=A02 files changed, 9 insertions(+)
>=20
Acked-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-GJL8Jf6wR815Diotm9MM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZpwoJAAoJEM553pKExN6DsSQH/0VY7WDADR5um/B5cwN1bEKS
ZuNml+6jJPGiYITji6vsSRiKmz/SR+QK85eUUMRPar3j2ufsaz8LhlhOKMhbj3Yk
k1rRtB7pvZsKopJy/jU9wND2TUS79HIVOl5Bs+zhq2Sv+LEkGX/nrn8DEezQ4XYL
zIFkvvFCi9fki5yyEyCJtodge1FJjnrEe87isbH7adipzldhzmmUWMNjaaLsFOIl
vAfdvjKIQROyfGn/mS+k9WyfMcFQt8O9gDcotDmBLmF9t+are7+Lh/m/iaE9FPTQ
fhPmVHykEkD5CzpG4DT7MBq3WyKHNp6QjJQwWa6dkr1uuqvD/DsPKIPRbd1CKeo=
=mLYx
-----END PGP SIGNATURE-----

--=-GJL8Jf6wR815Diotm9MM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
