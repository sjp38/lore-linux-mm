Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 4858C6B006C
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 09:22:06 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hq12so2012287wib.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2013 06:22:04 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 1/2] Fix wrong EOF compare
In-Reply-To: <1357871401-7075-1-git-send-email-minchan@kernel.org>
References: <1357871401-7075-1-git-send-email-minchan@kernel.org>
Date: Fri, 11 Jan 2013 15:21:55 +0100
Message-ID: <xa1tbocvby0s.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>, Randy Dunlap <rdunlap@infradead.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 11 2013, Minchan Kim <minchan@kernel.org> wrote:
> The C standards allows the character type char to be singed or unsinged,
> depending on the platform and compiler. Most of systems uses signed char,
> but those based on PowerPC and ARM processors typically use unsigned char.
> This can lead to unexpected results when the variable is used to compare
> with EOF(-1). It happens my ARM system and this patch fixes it.
>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Andy Whitcroft <apw@shadowen.org>
> Cc: Alexander Nyberg <alexn@dsv.su.se>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/page_owner.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/page_owner.c b/Documentation/page_owner.c
> index f0156e1..43dde96 100644
> --- a/Documentation/page_owner.c
> +++ b/Documentation/page_owner.c
> @@ -32,12 +32,13 @@ int read_block(char *buf, FILE *fin)
>  {
>  	int ret =3D 0;
>  	int hit =3D 0;
> +	int val;
>  	char *curr =3D buf;
>=20=20
>  	for (;;) {
> -		*curr =3D getc(fin);
> -		if (*curr =3D=3D EOF) return -1;
> -
> +		val =3D getc(fin);
> +		if (val =3D=3D EOF) return -1;
> +		*curr =3D val;
>  		ret++;
>  		if (*curr =3D=3D '\n' && hit =3D=3D 1)
>  			return ret - 1;

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

iQIcBAEBAgAGBQJQ8CADAAoJECBgQBJQdR/0VJIP+QGfrRUQHb1JqdrnDZ1w/W/w
3vgB7tW6+gbrHC84KYy0uiQHjgpzecSk7Sc7mM3SkJPi34OZIHlG9gkSD+HNRAbU
5BO7xMTvxpwNdvW6HtECj/Q2LlqrsbwWiRL0an9SvB67cnxTqrMxl2layDOwskqF
EE5U7XV8cxwkxFoWxqDx8RjMYwxTvqrI6O6HacpQzKKuRnk0HZYdnyzc6xWjqEuP
f9k+y8QHBAVmqTNFDhlqHuDuREKjtXB6JdzDXH/MQXTXNosQM2+Ngme4UgAviRyp
1mG+c8VllMAGesfohgc/VNQiJtc0RUdwjLq68tP6r67h+8BpbQx7SF+bJ3sRXSpO
K7mLLU4qlxw/yoyK50sa+xH5FMcvjmEQCDKLzhKMIPL0CZtPvV/5djVh4Qjdrrzu
8sjCNGoQgrqvZxE6CSjENIflzdhgEatGpEdOXi4rbOCFXvE/cgVgL4YtGfw5OFOB
LoF18rhMrgyg4stwZrPCZx0iKULyuUzxH7LKkGy3VlH2jge9YlqqJlMDdhkym2GO
I4IYi8LcVsKZ9zxZbpSM+PnyZ0k5a8vK0O8bJ8zlY1xA6dBMLAgjvYTpmN45w2KD
HrLegLNdT8TUXPTAki+CJ0CzVZqupyDCCANerkoCQy3efPX8EvwGm47sXx0X9Y42
ko/auHQbZkt3XUID+2Ho
=k20u
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
