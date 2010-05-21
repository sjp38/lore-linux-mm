Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C55C46B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 20:55:21 -0400 (EDT)
Date: Fri, 21 May 2010 10:55:12 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] online CPU before memory failed in pcpu_alloc_pages()
Message-Id: <20100521105512.0c2cf254.sfr@canb.auug.org.au>
In-Reply-To: <20100520134359.fdfb397e.akpm@linux-foundation.org>
References: <1274163442-7081-1-git-send-email-chaohong_guo@linux.intel.com>
	<20100520134359.fdfb397e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__21_May_2010_10_55_12_+1000_dmKoVdhhBYvCft9A"
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: minskey guo <chaohong_guo@linux.intel.com>, linux-mm@kvack.org, prarit@redhat.com, andi.kleen@intel.com, linux-kernel@vger.kernel.org, minskey guo <chaohong.guo@intel.com>, Tejun Heo <tj@kernel.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

--Signature=_Fri__21_May_2010_10_55_12_+1000_dmKoVdhhBYvCft9A
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 20 May 2010 13:43:59 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> > --- a/mm/percpu.c
> > +++ b/mm/percpu.c
> > @@ -714,13 +714,29 @@ static int pcpu_alloc_pages(struct pcpu_chunk *ch=
unk,
>=20
> In linux-next, Tejun has gone and moved pcpu_alloc_pages() into the new
> mm/percpu-vm.c.  So either

This has gone into Linus' tree today ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__21_May_2010_10_55_12_+1000_dmKoVdhhBYvCft9A
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEUEARECAAYFAkv12fAACgkQjjKRsyhoI8xHmQCUDkmYehloK9dIzgnFGC9c0USU
8QCfYkwGEe1GPduhl33b6nKkAJ+qW1c=
=hYuv
-----END PGP SIGNATURE-----

--Signature=_Fri__21_May_2010_10_55_12_+1000_dmKoVdhhBYvCft9A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
