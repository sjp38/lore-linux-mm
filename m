Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 171916B0260
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:44:29 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id yr2so35560122wjc.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:44:29 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id x89si28420657wrb.281.2017.01.25.13.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 13:44:27 -0800 (PST)
Message-ID: <1485380634.2998.161.camel@decadent.org.uk>
Subject: Re: [PATCH 1/2] fs: Check f_cred instead of current's creds in
 should_remove_suid()
From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 25 Jan 2017 21:43:54 +0000
In-Reply-To: <9318903980969a0e378dab2de4d803397adcd3cc.1485377903.git.luto@kernel.org>
References: <cover.1485377903.git.luto@kernel.org>
	 <9318903980969a0e378dab2de4d803397adcd3cc.1485377903.git.luto@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LW6dLfAszf3Gp4wHrYyw"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, security@kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, stable@vger.kernel.org


--=-LW6dLfAszf3Gp4wHrYyw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-01-25 at 13:06 -0800, Andy Lutomirski wrote:
> If an unprivileged program opens a setgid file for write and passes
> the fd to a privileged program and the privileged program writes to
> it, we currently fail to clear the setgid bit.=C2=A0=C2=A0Fix it by check=
ing
> f_cred instead of current's creds whenever a struct file is
> involved.
[...]

What if, instead, a privileged program passes the fd to an un
unprivileged program?  It sounds like a bad idea to start with, but at
least currently the unprivileged program is going to clear the setgid
bit when it writes.  This change would make that behaviour more
dangerous.

Perhaps there should be a capability check on both the current
credentials and file credentials?  (I realise that we've considered
file credential checks to be sufficient elsewhere, but those cases
involved virtual files with special semantics, where it's clearer that
a privileged process should not pass them to an unprivileged process.)

Ben.

--=20
Ben Hutchings
It is easier to write an incorrect program than to understand a correct
one.


--=-LW6dLfAszf3Gp4wHrYyw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAliJHBsACgkQ57/I7JWG
EQn0NA/+OGkyAVJSb832BMVRKcL5nFM63tP0zcTG4i9lG8XrWcX5M9kpI3TrOKTI
qjY+WHim3Px0EmveiomsjvJ3N2ND5sXBvUQr3uNHqPA+onWuhq0KfD12MzJowg1P
zNJJ7kaXqAxRXMXcO58GmS7yBZXOjhUJLneWjIk3kSJzS125z4VuKXPk3d9j06Ah
YKw1ESow2fC7qIlHGRe8PrddPQSmbxyXG6jrAjqKqOyQZ5loIzNVQbCQcJNCPy3F
H1ETJdy1rzFswNZ7rASGyZ3y1QtVHPOWUMD4a2mkAGNZy3VC9GWpknV4xh5r+/jA
uMahE3HuOSjzXQNI75NKn7gd6fdObY+U2tn09Tyrrz+qHWGs77F1fP+zYU9nslX2
ZH1ZumruCUPEkmqO7YQSTrpCWWuqumM5J3VZwrKGofJxOluJB2mb4dDxJzz3Ipd9
rxMNx2cwdVAYLub5TYJbkZJONhYJAvZHyauTDh5FuPB/MWQJSblHDxq9Vu+9jxge
73nkBq3sIOUY6sj8BYt9cwzPvL+OgfwGIIUP/nwL+dAfYvMQbmP0c0le59tFpJ2v
r67GS/6M8QFusHTbUdGrXMciwB+IGq/xJ/YS6GqwkVamEHsLX1OP7cjdsqkEc6k4
dq3ND4rDGRtcT18hH46gMKYFp8A/5ol2MbRRHUWOsZIPVrylzWk=
=q2V+
-----END PGP SIGNATURE-----

--=-LW6dLfAszf3Gp4wHrYyw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
