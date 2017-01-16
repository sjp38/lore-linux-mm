Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34A836B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:48:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so243050483pfa.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 01:48:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id u22si21100546plj.0.2017.01.16.01.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 01:48:55 -0800 (PST)
Date: Mon, 16 Jan 2017 11:48:51 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Message-ID: <20170116094851.GD32481@mtr-leonro.local>
References: <20170116091643.15260-1-bp@alien8.de>
 <20170116092840.GC32481@mtr-leonro.local>
 <20170116093702.tp7sbbosh23cxzng@pd.tnic>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="FFoLq8A0u+X9iRU8"
Content-Disposition: inline
In-Reply-To: <20170116093702.tp7sbbosh23cxzng@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--FFoLq8A0u+X9iRU8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 16, 2017 at 10:37:02AM +0100, Borislav Petkov wrote:
> On Mon, Jan 16, 2017 at 11:28:40AM +0200, Leon Romanovsky wrote:
> > On Mon, Jan 16, 2017 at 10:16:43AM +0100, Borislav Petkov wrote:
> > > From: Borislav Petkov <bp@suse.de>
> > >
> > > We wanna know who's doing such a thing. Like slab.c does that.
> > >
> > > Signed-off-by: Borislav Petkov <bp@suse.de>
> > > ---
> > >  mm/slub.c | 1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 067598a00849..1b0fa7625d6d 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -1623,6 +1623,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> > >  		flags &= ~GFP_SLAB_BUG_MASK;
> > >  		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
> > >  				invalid_mask, &invalid_mask, flags, &flags);
> > > +		dump_stack();
> >
> > Will it make sense to change these two lines above to WARN(true, .....)?
>
> Should be equivalent.

Almost, except one point - pr_warn and dump_stack have different log
levels. There is a chance that user won't see pr_warn message above, but
dump_stack will be always present.

For WARN_XXX, users will always see message and stack at the same time.

>
> I'd even go a step further and make this a small inline function,
> something like warn_unexpected_gfp(flags) or so and call it from both
> from slab.c and slub.c.
>
> Depending on what mm folks prefer, that is.
>
> --
> Regards/Gruss,
>     Boris.
>
> Good mailing practices for 400: avoid top-posting and trim the reply.

--FFoLq8A0u+X9iRU8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh8lwMACgkQ5GN7iDZy
WKc/ug//TRYm9M+3WN58c19PyGTKU/HwVKA4lnDie6D4BGdkN/Ag/KJe5iZcz+2f
KuUpOOSIrwHDnPMVt4phLVGbzAdKH6ccodLScBjfWEZ0ACYvi8cnVWGMpKoBeE3+
p/tXNg5l9M4GWtz51ECZWN+J+qQRFTRnmy2XEbQiIJ/xoM/AMIBTuUyKoej3txn9
3wSCF+XhdFsMHggn5Gz9O2a+fGdkUF5RTMkMPk/Nh8JldhYJYfPj94vGzIlkdsMN
+tpccX6B/D4hEvXzxw62ObkxP+G5nEkRcma89JIGKSlzc2oO6SfX/nt0TUXcAN1C
N71lGBFTnbfuBHp4N70LUOuUFYm8uj2s2tO2RfNVPf850C/W9/87KjTgm3Kf49HZ
xyyoM976O+F2/SGMti76XTct07tL9PdSeVdBrMI5Q9LZsdKnyMfDicN5oGik9Aak
6zbW4REGlGPueTFoBdBLi8iKeaGmS+PZcp9SOimED67Mzu5L+vj9q4+5pk0+wyl+
Gw+ydwvr62l0SbJrbWtcW/SVUSR9qyw+XDODVOWftSnO130YaxGHhjdVeuMRqF1T
XItGDk5zHqKYpmZeuUX5X3mEBKBY3OwqZUYhuMNkDJVApkJ0Y4LW7awESiE+fxDv
DpmcISxJLNoB/1Sp5qWeCgSo5e3LMu7XjPRZU1VLiwKZJR4LMn0=
=BaMf
-----END PGP SIGNATURE-----

--FFoLq8A0u+X9iRU8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
