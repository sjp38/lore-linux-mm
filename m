Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70D776B02C3
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 14:55:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n64so21353422qki.10
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:55:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c21si5834910qtc.506.2017.08.30.11.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 11:55:53 -0700 (PDT)
Message-ID: <1504119351.26846.79.camel@redhat.com>
Subject: Re: [kernel-hardening] [PATCH v2 25/30] fork: Define usercopy
 region in thread_stack slab caches
From: Rik van Riel <riel@redhat.com>
Date: Wed, 30 Aug 2017 14:55:51 -0400
In-Reply-To: <1503956111-36652-26-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
	 <1503956111-36652-26-git-send-email-keescook@chromium.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-5yNfw2/9DwlhFVGK3aNK"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: David Windsor <dave@nullcore.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


--=-5yNfw2/9DwlhFVGK3aNK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-08-28 at 14:35 -0700, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
>=20
> In support of usercopy hardening, this patch defines a region in the
> thread_stack slab caches in which userspace copy operations are
> allowed.
> Since the entire thread_stack needs to be available to userspace, the
> entire slab contents are whitelisted. Note that the slab-based thread
> stack is only present on systems with THREAD_SIZE < PAGE_SIZE and
> !CONFIG_VMAP_STACK.
>=20

Acked-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-5yNfw2/9DwlhFVGK3aNK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZpwo3AAoJEM553pKExN6DTIAIAICxbgOqL7sjfwNyLMbbVJnN
UrgRUrD2Hx7/6O7LWTaS8sWotYyl5bPxKSBajvhqLEs+H2LRYhpjPXmHH5sA5e8T
2o8NV7Li3EjqUgRm5tYP0lz3ejdk7OJPpI8Tc6lMgGRW7B7f9mI8WlR7f6cV9fVx
p2hA2wLF1IxMOtI99O/JyeAaDleKuLjc+TUN5j5HM/UZ97EZkXAag2eLxtrMWyHF
jOSuYe7Jf0gXggS2KyWIGo7fxhERhqRuLsLTJexDGb5LZsxGDDr2sJebv59Q8reS
oL70reLJLvcoVkgXzeKay1nYChEv/rH4+N1AwJOCXJ4ny79k7O/vp0ESvRgTA+Y=
=uqD+
-----END PGP SIGNATURE-----

--=-5yNfw2/9DwlhFVGK3aNK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
