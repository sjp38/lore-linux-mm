Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1116B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 14:55:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p13so21842211qtp.5
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 11:55:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i67si5906018qkd.281.2017.08.30.11.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 11:55:06 -0700 (PDT)
Message-ID: <1504119302.26846.77.camel@redhat.com>
Subject: Re: [kernel-hardening] [PATCH v2 26/30] fork: Provide usercopy
 whitelisting for task_struct
From: Rik van Riel <riel@redhat.com>
Date: Wed, 30 Aug 2017 14:55:02 -0400
In-Reply-To: <1503956111-36652-27-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
	 <1503956111-36652-27-git-send-email-keescook@chromium.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-gDrkBpl1tnRDV5mbeNIO"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Nicholas Piggin <npiggin@gmail.com>, Laura Abbott <labbott@redhat.com>, =?ISO-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, David Windsor <dave@nullcore.net>


--=-gDrkBpl1tnRDV5mbeNIO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-08-28 at 14:35 -0700, Kees Cook wrote:
> While the blocked and saved_sigmask fields of task_struct are copied
> to
> userspace (via sigmask_to_save() and setup_rt_frame()), it is always
> copied with a static length (i.e. sizeof(sigset_t)).
>=20
> The only portion of task_struct that is potentially dynamically sized
> and
> may be copied to userspace is in the architecture-specific
> thread_struct
> at the end of task_struct.
>=20
Acked-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-gDrkBpl1tnRDV5mbeNIO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZpwoGAAoJEM553pKExN6DkMUH/jqMAHuDXRsICKlav1+hX4Na
v5WTBKlFUC6rzz+SSInr4t67RfGP6c8EhcaZdwpi4A/xyqL9ZAMzaEMK9uVGNZoN
93qbNj3QtYdmu9xJF5JmfLr3+TRuK7HEkAcpCF0Um4yCpH79XsWtc2sbfFbK0+HC
V5rRv2sCM4OWiR9czzDNYiE82c+F5gdAgTnF4lEnrkKvmqKMVT+T36XvK6F1qoa+
ExAhSVC8iyXnIowea+zBa5Rw5JxGFy/TclpSxsBEj4V4/Mv1X58V0eLgjP/kVSVg
Tcp4JnLHholSfSklqWMkgyq3Do+lPIlorAQqos8OFvwyuYNdg6JYEiTgUED/pUY=
=9/Pr
-----END PGP SIGNATURE-----

--=-gDrkBpl1tnRDV5mbeNIO--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
