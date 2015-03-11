Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4A11B90002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 00:48:41 -0400 (EDT)
Received: by padet14 with SMTP id et14so8228108pad.0
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:48:40 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id mj1si4969303pdb.40.2015.03.10.21.48.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 21:48:40 -0700 (PDT)
Date: Wed, 11 Mar 2015 15:48:30 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] zsmalloc: Add missing #include <linux/sched.h>
Message-ID: <20150311154830.32d4981e@canb.auug.org.au>
In-Reply-To: <20150310231557.GA4794@blaptop>
References: <1426023991-30407-1-git-send-email-geert@linux-m68k.org>
	<20150310231557.GA4794@blaptop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/GOvaB3NzmP25b+m0dX/ca.."; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-next@vger.kernel.org

--Sig_/GOvaB3NzmP25b+m0dX/ca..
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Geert,

On Wed, 11 Mar 2015 08:15:57 +0900 Minchan Kim <minchan@kernel.org> wrote:
>
> On Tue, Mar 10, 2015 at 10:46:31PM +0100, Geert Uytterhoeven wrote:
> > mips/allmodconfig:
> >=20
> > mm/zsmalloc.c: In function '__zs_compact':
> > mm/zsmalloc.c:1747:2: error: implicit declaration of function
> > 'cond_resched' [-Werror=3Dimplicit-function-declaration]
> >=20
> > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Minchan Kim <minchan@kernel.org>

Added to my copy of Andrew's tree (and thus linux-next) today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/GOvaB3NzmP25b+m0dX/ca..
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU/8kiAAoJEMDTa8Ir7ZwVB2kP/2OoDqaGbwmAjsr+nWQPWMrM
1GnlHeocvwq1MQVtY3aqIUgPKPKr0CMAU4AbGO32eHoYRBTu1Gvxo/gxR2/pNN3o
kwZx1yD/QQ2Rq2ikLKoseIbsTT6DDDhLOJUxPVfmsaVtlC9gdrms8um6rA44Y2aS
0YGfd+KfecUOFIebYrQrkxzJw/HvVEqwts/pIQAwoPocqrvTVYwGl4nC8M31atgk
PqLp7zk3PbnofNagD1a/3AqGQMyW0vLlnJBppisznyr8TJdpDlvzhTG8ZFprKqAY
u/1IIIdT9uk5lH8/2PiEm4QKe1/AbnaLDpBV/WSbl13tMLStFKCnDC3Kiqz+WWsY
mYiN9nLDagX+T9e7b/fFjcPkguDopl5vEcrq0OErG0FlLRhVNLSiCh54AtqbMF9f
P0rqAouRIJDRv0kofD/KbC1bqYzTgFuVlZKvGdKxSbFgwfko77HO8P0cQAl8oM+n
KnQnyEv0/XqUMLm2+yIhsovNXEsqJ5eXyxaHJsssY/mtHlQR4gD9hK/nOiD2F66h
tLLN6BAqovJEtZ2CPeffnwgZP9IVNAERigLg1eNSpTxMkezCyRYK/UFCiNXs4DrT
03W8xbXOBvr5eKeamim7ptQ9rgeKvGCwMPFLikLtLK4eRWH7n57Eqo09Z4Lw0o18
KWw2MpmU+7p1YcO4WfMl
=TNJX
-----END PGP SIGNATURE-----

--Sig_/GOvaB3NzmP25b+m0dX/ca..--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
