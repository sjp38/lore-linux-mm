Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9726B6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 01:43:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so27356816wme.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 22:43:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si7147222wma.116.2016.04.26.22.43.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 22:43:22 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 27 Apr 2016 15:43:11 +1000
Subject: Re: [PATCH 02/19] radix-tree: Miscellaneous fixes
In-Reply-To: <1460644642-30642-3-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com> <1460644642-30642-3-git-send-email-willy@linux.intel.com>
Message-ID: <8760v3wqs0.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 15 2016, Matthew Wilcox wrote:

> Typos, whitespace, grammar, line length, using the correct types, etc.
>
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

>=20=20
> -static inline void root_tag_clear(struct radix_tree_root *root, unsigned=
 int tag)
> +static inline void root_tag_clear(struct radix_tree_root *root, unsigned=
 tag)

Changing "unsigned int" to "unsigned" - Bold.

>  {
>  	root->gfp_mask &=3D (__force gfp_t)~(1 << (tag + __GFP_BITS_SHIFT));
>  }
> @@ -159,7 +159,7 @@ static inline void root_tag_clear_all(struct radix_tr=
ee_root *root)
>=20=20
>  static inline int root_tag_get(struct radix_tree_root *root, unsigned in=
t tag)

Not doing it uniformly - Priceless.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXIFFvAAoJEDnsnt1WYoG5oLcQAMQH/Kn7DGnUpWK6H7pdLKyX
T46I00WDGEtG6RAHIP5FMAdMWZgWjxjdnqZOD2RhISDzPSjsMoP9NzjiQ6N0IEYa
xRECMxikC1S8/oR2GM8N410qo0rVLhcT+P1zQXOY2SWvvg36sfEfYwsUoJvjVIHG
fCV+Xz//qK7PXqwsaPGRoeyQxuufY6yqbC41524FFsaEYdyNIfXcaRr9xbcjQhiz
RpO4WUE/8rjixFfFyoP1oe8LqzcL3WTfEti377H1aaeGlOeTr3azTe42I0/nIpAG
WmcYTcbCklAO+6hCVZBcz0fho+yTKiEERklVNJ+oxYRroGi+CsPBT0AIz//L5gir
0bhGZz6mK6vEGszrSm04f5kp54qdChDUKd1T0mmUS0ChcCua6JRaXEYTYGq7kNyZ
opunAxDw8ftz80hITWyBENFCHW6Z2vJaaaXOMzmK4Cyy3MYTaFVXyFyozU7LkyB9
d8tCOfPHkfRyxq1iulFJQZ1j4F3QSP+10FS8ikGH2WcEhZ/jWrU4uhT2KnSjx9kN
MOTFclVATVehwX96cfti94CKm88WzFNSD1PdmrOl1UAoeO1l4t1AOab3M4Qz5g/Q
KNpgD7PXfPlwu3bUhsFkQYTdFFonQ+6tCNHgliGQfYu0hhfypSkDIIEiKd/H+mz9
ampP7ANW0rahW5xelkZQ
=/93p
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
