Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEAD6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:18:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 201so83155617pfw.5
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 02:18:52 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id f123si21136670pfb.188.2017.01.16.02.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 02:18:51 -0800 (PST)
Date: Mon, 16 Jan 2017 12:18:52 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH] mm/slub: Add a dump_stack() to the unexpected GFP check
Message-ID: <20170116101852.GF32481@mtr-leonro.local>
References: <20170116091643.15260-1-bp@alien8.de>
 <20170116092840.GC32481@mtr-leonro.local>
 <20170116093702.tp7sbbosh23cxzng@pd.tnic>
 <20170116094851.GD32481@mtr-leonro.local>
 <20170116095522.lrqcoqktozvoeaql@pd.tnic>
 <20170116100930.GE32481@mtr-leonro.local>
 <20170116101310.4n5qof3skqpoyvup@pd.tnic>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3oCie2+XPXTnK5a5"
Content-Disposition: inline
In-Reply-To: <20170116101310.4n5qof3skqpoyvup@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--3oCie2+XPXTnK5a5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 16, 2017 at 11:13:10AM +0100, Borislav Petkov wrote:
> On Mon, Jan 16, 2017 at 12:09:30PM +0200, Leon Romanovsky wrote:
> > And doesn't dump_stack do the same? It pollutes the log too.
>
> It is not about polluting the log - it is about tainting.
>
> __warn()->add_taint(taint, LOCKDEP_STILL_OK);

Thanks,
I had something different in mind for word "taint".
Sorry for that.

>
> --
> Regards/Gruss,
>     Boris.
>
> Good mailing practices for 400: avoid top-posting and trim the reply.

--3oCie2+XPXTnK5a5
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh8ngsACgkQ5GN7iDZy
WKdzWhAAtOdOKuRojA/IuGghqpVnhmz29oD10rUFBiJvPIOMH8XdHvJsA5/Z36HC
FD3ALo88t1hgq24AWKK/F6V3Ca8Tf1sOaCyg7STMy0ob/XqCAXNQnvJzykb8bdZF
cG9UQaxhxduyf8l/N/nG8rtEkdMmUmBylUIIMbypvWfzqU4ipI/aHF4jzDs+9m16
JsVaVWZjwpFqKRrjQvTNsTh7rhT4E9Cl6H1i123od8krrOYq8ilTzjEQT/1Z6lyL
nRzx5l27RvYVO2iZXO5QVZL9kLH15yzI9qDsmsN5VndYTeXzE85KgduZani9wYA6
QTwnYuGHCuUhQUe3zX5mBRL5BuC3YJbwhLRLT3e8cIU53RLRKLLLM9CF6LP9RRHO
Qd+H1KKA+T7g+wbYjHfUnlrLlrq9l/iMpAge5PAmioHqlkCY/SeSTD7UslSHSHBf
YIfRrrTtxJKqDI45YPX0QUIYDzuPt+9lou+8RPqdiUcRceyVDSfhtlqLGQYKbxn1
OQAnjHBUdSC51e6wdeIhASKMjU7U4NvhmTU3j26cS4dgZbm5Bi9bi7TgZlINiyl1
Aq3V/E7+KaxL/CM6LkohRFdShZYKWYlroLeBRWt0AXvu6fLevPPrBvwOrkYLoh0K
ZTT0+2b+PRXsQSohqNEiEFctA4E/t8lz5S7C0AQpgUynDjBSPIE=
=1wzQ
-----END PGP SIGNATURE-----

--3oCie2+XPXTnK5a5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
