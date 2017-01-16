Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 773E26B0069
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:09:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f5so45676276pgi.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:09:46 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id u27si21130212pfj.77.2017.01.16.02.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 02:09:45 -0800 (PST)
Date: Mon, 16 Jan 2017 12:09:30 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Message-ID: <20170116100930.GE32481@mtr-leonro.local>
References: <20170116091643.15260-1-bp@alien8.de>
 <20170116092840.GC32481@mtr-leonro.local>
 <20170116093702.tp7sbbosh23cxzng@pd.tnic>
 <20170116094851.GD32481@mtr-leonro.local>
 <20170116095522.lrqcoqktozvoeaql@pd.tnic>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="0QFb0wBpEddLcDHQ"
Content-Disposition: inline
In-Reply-To: <20170116095522.lrqcoqktozvoeaql@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--0QFb0wBpEddLcDHQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 16, 2017 at 10:55:22AM +0100, Borislav Petkov wrote:
> On Mon, Jan 16, 2017 at 11:48:51AM +0200, Leon Romanovsky wrote:
> > Almost, except one point - pr_warn and dump_stack have different log
>
> Actually, Michal pointed out on IRC a more relevant difference:
>
> WARN() taints the kernel and we don't want that for GFP flags misuse.

And doesn't dump_stack do the same? It pollutes the log too.

> Also, from looking at __warn(), it checks panic_on_warn and we explode
> if set.

Right, it is very valid point.

>
> So no, we probably don't want WARN() here.

I understand, Thanks.

>
> --
> Regards/Gruss,
>     Boris.
>
> Good mailing practices for 400: avoid top-posting and trim the reply.

--0QFb0wBpEddLcDHQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh8m9oACgkQ5GN7iDZy
WKdcAxAA0X7IMaqY7MOnSkuPh2CW24JWHvc3+LXrJ1HJ8frAg3I1hqKAojvB/qog
imXuHyz5KzvK4UBWVdoMFME8HwafcVsWPOF6zLAro3IUSTBzV9cJoWo+vl7o0iFi
zSRE2A9Sek4X/VzmKfB+AVhLtVeVMaCTitLXgMx3wLSe3Ub5vWjgin9/iRyk2Bwq
nBgu1uGr7Xk/5OmC3Pv/WBBYaPf27o848cParnavvXGEX/rlt+dt4iKcy6YJENpt
ZX3B3DrCcsUapxZLixzCPquXwNgnSP/UUvpGaZ+pbRXN8bTF8Q2HCk+WAk2QqBxm
FkO93vFVYhPJfPBE4lh6vr+yJXo1XW3WanBvuu08CgslBECEGMChDLdqzod0Fuj0
6ME88XRhtgnXGi8OA9WMxR40MtuG0+2ZMnfrzNSJdrD35+z2kRMCJNpEahqS7epG
fAryl/StzFiryu6EaVnjaeeWb1hQrb61odVT0IJm39WxZPM0cu1aARwx6Y0NWJdP
0cDj5Kp1MMmKiytYL/LIh1Cu7y2OW2JGP4vw06b8mXuC84HkZmbjv4zFtdYh1ftw
o58X7FmmfGy3SWb4A1SKy+EfcQU6bds55u+BMp5R3VGHqB/l5YhXaHjcw9YS2pzh
nszHr2pSdDECCvy5ldT6vKjXn8+Ws7iW6g5RUXpKVC5N8eWqogk=
=dOTj
-----END PGP SIGNATURE-----

--0QFb0wBpEddLcDHQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
