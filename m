Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A97406B02E1
	for <linux-mm@kvack.org>; Mon,  1 May 2017 11:15:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p9so71320012pfj.8
        for <linux-mm@kvack.org>; Mon, 01 May 2017 08:15:30 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id t16si2706542pgo.63.2017.05.01.08.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 08:15:29 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id c2so5993966pga.2
        for <linux-mm@kvack.org>; Mon, 01 May 2017 08:15:29 -0700 (PDT)
Date: Mon, 1 May 2017 23:15:26 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/3] mm/slub: wrap cpu_slab->partial in
 CONFIG_SLUB_CPU_PARTIAL
Message-ID: <20170501151526.GA1110@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
 <20170430113152.6590-3-richard.weiyang@gmail.com>
 <20170501024103.GI27790@bombadil.infradead.org>
 <20170501082005.GA2006@WeideMacBook-Pro.local>
 <20170501143930.GJ27790@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
In-Reply-To: <20170501143930.GJ27790@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 01, 2017 at 07:39:30AM -0700, Matthew Wilcox wrote:
>On Mon, May 01, 2017 at 04:20:05PM +0800, Wei Yang wrote:
>> I have tried to replace the code with slub_cpu_partial(), it works fine =
on
>> most of cases except two:
>>=20
>> 1. slub_cpu_partial(c) =3D page->next;
>
>New accessor: slub_set_cpu_partial(c, p)
>
>> 2. page =3D READ_ONCE(slub_cpu_partial(c));
>
>OK, that one I haven't seen an existing pattern for yet.
>slub_cpu_partial_read_once(c)?

Thanks~ You are really a genius.

--=20
Wei Yang
Help you, Help me

--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZB1EOAAoJEKcLNpZP5cTd0pIP/RP17saBDystBvelrgluJ1xH
YjhutyHWtqUmqKXzRL8xCI9ZR/0GTmoo4s1jwaYrmxGmQX51C014A7BGHCJj3/3Y
8yTopbPexEjifDHorLtvSmXgq3ZqdvNDI3f2qnUwTh1LyQOVb1eK4T8ZjNJQbflV
f1zWb8HeI5Sl4Qsoq2Zi4KGdBvYtvWbiG9gRsdqcqU0bFC30OjnA3NP4kIOD1IZF
OtmgHgBZOlXGCIAUkNF7H/YBx/zN1OnnuzsSe6/5D9M9HClrIiRevw5uGkKxVo94
/nhpuo+qhqpRd8x3KOmpxMFkElj7S54APPkpI2XsfXVWzg7RTVPRqVeFEw9fsBdv
cI4qzEPclFdc64qvk17HbNofmImJvXlM9hKAuywz60lZSX3UQ5Qu+zPECtfyLpYU
GGQ8gp4xWLEq0ep5a+iDHUsminUfa14xJLMSWUH40rpwrLMr03lMMvMwqAZYbxJ2
mfHcqm/pTRBjub00uf5G01wk0mZmyWCeDPg6f5z5EboWAC5jsPL6+/2ZnjvA9IYL
L2tMjcu6hv7Aayx7HUunUZ6DZ6v+CAqzz7Aqgt4dQahxxVIQB624kmEvvDV1amlX
Egl+Cyl7kJkn7U1Lhu6poE5XsirnLsR0DnTBjzREMogKKWND16QYHiGcrsg2+ynd
8ZGlxbDCAT6NFnPCCoje
=c6ed
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
