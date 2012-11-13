Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3675C6B0083
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:47:16 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so5001077eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:47:14 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: Remove unused variable in alloc_contig_range()
In-Reply-To: <1352709906-10749-1-git-send-email-thierry.reding@avionic-design.de>
References: <1352709906-10749-1-git-send-email-thierry.reding@avionic-design.de>
Date: Tue, 13 Nov 2012 15:47:06 +0100
Message-ID: <xa1tr4nxv9ud.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@avionic-design.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 12 2012, Thierry Reding wrote:
> Commit 872ca38f7afd9566bf2f88b95616f7ab71b50064 removed the last
> reference to this variable but not the variable itself.
>
> Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

I could have sworn that someone (Marek?) sent that patch already.

> ---
>  mm/page_alloc.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6b990cb..71933dd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5822,7 +5822,6 @@ static int __alloc_contig_migrate_range(struct comp=
act_control *cc,
>  int alloc_contig_range(unsigned long start, unsigned long end,
>  		       unsigned migratetype)
>  {
> -	struct zone *zone =3D page_zone(pfn_to_page(start));
>  	unsigned long outer_start, outer_end;
>  	int ret =3D 0, order;

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

iQIcBAEBAgAGBQJQol1rAAoJECBgQBJQdR/05toP/iNhRiJJejr3V6cY2HOFsP7L
8mQNkqyXEYqiMaXC5/YNXP+myuIIO1czk7NzbuFXuDOVLtvvTQQ4t6NsO7bpa0yl
6QdZGm1X3kj57HhDDj4NVhlnbWAArwAwoePOupifFnEQ80W81Y7k+ly78W5lYIXW
ZeSlrjJ6Gsz+8DkQaHs9tvaA9cAzXfuiYWmBDSOIG6gjxbOcTnZY3CqDqLLqEple
jUT7U4lac6PAWFgxe0t7+LvblqadgaUjtqaNWATPtfzzs/QwhCNET6AMZSna/e+t
Kw0iDbMHFQshAqEAamXaqbnKqoP/F6Lz7IQDuJP/bYIga5mUEs1yFVoBG6Z1FgH6
bd/Zwpef/hXJQKLD1eLmQxboJC7N5+EpcrUg1P6UyzvW71qydkb965Mx85PVjvxO
U69U01QCLVaAH0PEC2CJjhjNhe3A68Q/5i6JkQYUGcGb6AbgRM32vySBaTdH5I+T
TdHl+XhbvsKfsor6Q8p2NrJyAELx3CNP4TpemNiJWX9TFPtlGKr9/kOdQcAqagBa
wRDd08qfbj/TlFCnhgYKdahWEEoH/HKqrzVQdYCvbQPdF2SS8z4zljE98D2YzGWT
CFkJwSDA3+ysgwkZwhm0x25eZMk2cz4//C12JlEzKFSjAOcCcpNyRBFECWWm7h6P
dio4/cBM3wQxgtgpG8eS
=+o4b
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
