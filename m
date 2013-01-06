Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id F16276B005D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 11:02:02 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id w11so7917854bku.17
        for <linux-mm@kvack.org>; Sun, 06 Jan 2013 08:02:01 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: compaction: fix echo 1 > compact_memory return error issue
In-Reply-To: <1357463980.1454.0.camel@kernel.cn.ibm.com>
References: <1357458273-28558-1-git-send-email-r64343@freescale.com> <20130106075940.GA22985@hacker.(null)> <AD13664F485EE54694E29A7F9D5BE1AF4E5BCD@039-SN2MPN1-021.039d.mgd.msft.net> <20130106084610.GA26483@hacker.(null)> <AD13664F485EE54694E29A7F9D5BE1AF4E5E1F@039-SN2MPN1-021.039d.mgd.msft.net> <1357463980.1454.0.camel@kernel.cn.ibm.com>
Date: Sun, 06 Jan 2013 17:01:48 +0100
Message-ID: <xa1t1udyjo5v.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>, Liu Hui-R64343 <r64343@freescale.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "minchan@kernel.org" <minchan@kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 06 2013, Simon Jeons wrote:
>> >write(1, "1\n", 2)                      =3D 3

>> Here it tells it.=20=20

> On Sun, 2013-01-06 at 08:48 +0000, Liu Hui-R64343 wrote:
> Why this value trouble you?

Because write() is supposed to return the number of bytes successfully
written.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ6Z/sAAoJECBgQBJQdR/0vc8P/A/mtUEbevpmgRTO9TXUtgXG
CA+MzCT7txiqZbm0pqtx/zE0WmrqPCVWD37kKaGhrXMTh4qsIrgjxyyxR2tDgk37
HnRN3lhZHlKtBOuym2PEd7aTJF8mQv686lK/L5mqU6AFGzSaUlCdyYq3Z3c59nfS
Y3KE7e6FmglTIwtc1/a/VNoOSLMUOxR9rt3FJqy9JMk98gHRH+bgdwCdOdbPKogV
fGfW7LmRtGMo3YzDgAj0DoXlCwYZJ4rBttshF9dVuTcmOSxVZsxgb96joEiecvb6
4nq+SNInik928TPZTUm6LmPJBmUabLT3fBPwKh3WsaZ95V/x48qLWHERXZSgux1k
tPQFXT1HQIX4hK3Vfzp4WCHfD6g6SVG6EmxLp5N8dWomxFrZSp6Fg+mvry968xzL
cyFm5GYFFxEINlKDZfEl06IjbM4uHgcXTzxwddZSfHr4yokMIhtmKmmlRUuNF426
YJ67nZX23829DXzlH4EhH2qhhISGjjiU2JkQ9Z9ABSo9ptm4hTBbg+0sxNbdCPSv
qjSTz+2xvZuGp+FJ5+n2dLw+rq1hRB8F/GPIjJxdz7gjROAWgFWade3hhnmBtGTL
w6Jctfpomg/vRmjBkXXcbepv5DXAPNrhGYFZVyixvKSpiEcEDpW5zVTMi499whAu
JUtPihQw+2UG/iR52s5t
=CGlX
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
