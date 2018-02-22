Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC2526B02A6
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:49:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u1so2265428pfi.20
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 01:49:13 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m197si3577858pga.206.2018.02.22.01.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 01:49:12 -0800 (PST)
Date: Thu, 22 Feb 2018 09:48:44 +0000
From: James Hogan <jhogan@kernel.org>
Subject: Re: [PATCH 00/13] Remove metag architecture
Message-ID: <20180222094844.GB9891@saruman>
References: <20180221233825.10024-1-jhogan@kernel.org>
 <20180222092654.GN25201@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="SkvwRMAIpAhPCcCJ"
Content-Disposition: inline
In-Reply-To: <20180222092654.GN25201@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-metag@vger.kernel.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>, Marc Zyngier <marc.zyngier@arm.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Linus Walleij <linus.walleij@linaro.org>, Wim Van Sebroeck <wim@linux-watchdog.org>, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Wolfram Sang <wsa@the-dreams.de>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-gpio@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-media@vger.kernel.org, linux-i2c@vger.kernel.org


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 22, 2018 at 10:26:54AM +0100, Peter Zijlstra wrote:
> On Wed, Feb 21, 2018 at 11:38:12PM +0000, James Hogan wrote:
> > So lets call it a day and drop the Meta architecture port from the
> > kernel. RIP Meta.
>=20
> So long, and thanks for all the fish!
>=20
> Nice cleanup though, most welcome :-)

I thought you might like it ;-)

> Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

Thanks
James

--SkvwRMAIpAhPCcCJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEd80NauSabkiESfLYbAtpk944dnoFAlqOkfYACgkQbAtpk944
dnoHNw//araZkIz0fvrAT593YR6P+Sff9uhB2R9cOsuzBhV6cv3yci06pKrMLv3u
d5dIurnPaZB1mhADAPXB4B0jrvqx0evAJ45CKS8rAKZSjZNKrAnrEpOAlkPgo1xp
sFPCzh98J7qcYNkR2IRDtfWbC0ARAY8iuaN8Ejc7Y25t4POGh+6ZGloBisgZq6Af
H1IwLvM4gRTT2qkxoRO/dEECFLor06EXSp2AdibvaTb8Z00kWM8Tig+NFCRkDvR+
PAlL7D4Iv6GEZzU2Bac6caWFcWIfV4OzOHDiFcVUWgsWveuQGiX5F4q1dJSpGgRl
IPErO/pUMDUubn6bAZAWW/5m3VrKiyjwOixADGmY1O+LjsEjMfpO/gnuJJiDCv9J
7JgMmz4DnNtephmG2ZQYiaM4qL4ErNW+CunOaGl/tvHBJxgpzCrcaDHmBpw1Jpvc
FBqqz5p8G+FM+qSPIrhrymF9dhVyO9VuO8qtuVekO5PzgoGm7Gb+1gr/3brKodSd
BN7AdOCVKn0Zpj28KRkw7nL0GQKXsH4yCou68DQxWEx0gt+aaurAIMkPsPuM2lYC
pLqgNbj93IEYmSj0TnTcmcfVAl0WvviGbVmMo57YuU8fpFW1FHDji4R9R/zulmtF
MCUFugKKc61StB/kH95RHaehJ6Rly+yz7ioWI5JlrwZCbNmFJKM=
=gZvt
-----END PGP SIGNATURE-----

--SkvwRMAIpAhPCcCJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
