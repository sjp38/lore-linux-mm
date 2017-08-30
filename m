Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55CE82803A5
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 01:31:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t82so915735wmd.10
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 22:31:29 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id f13si4763405edb.32.2017.08.29.22.31.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 22:31:28 -0700 (PDT)
Received: from mail-wr0-f200.google.com ([209.85.128.200])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <juerg.haefliger@canonical.com>)
	id 1dmvb5-0003yz-Tj
	for linux-mm@kvack.org; Wed, 30 Aug 2017 05:31:27 +0000
Received: by mail-wr0-f200.google.com with SMTP id a47so7438418wra.0
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 22:31:27 -0700 (PDT)
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com> <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
 <20170823165842.k5lbxom45avvd7g2@smitten>
 <20170823170443.GD12567@leverpostej>
From: Juerg Haefliger <juerg.haefliger@canonical.com>
Message-ID: <2428d66f-3c31-fa73-0d6a-c16fafa99455@canonical.com>
Date: Wed, 30 Aug 2017 07:31:25 +0200
MIME-Version: 1.0
In-Reply-To: <20170823170443.GD12567@leverpostej>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="A6exSVd4e9U3pOIGSQJPXxWSpn5KhIE8w"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--A6exSVd4e9U3pOIGSQJPXxWSpn5KhIE8w
Content-Type: multipart/mixed; boundary="irH4NmKN7wMDrNE8J2tbOkjU4JO732xNG";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@canonical.com>
To: Mark Rutland <mark.rutland@arm.com>, Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 kernel-hardening@lists.openwall.com,
 Marco Benatto <marco.antonio.780@gmail.com>
Message-ID: <2428d66f-3c31-fa73-0d6a-c16fafa99455@canonical.com>
Subject: Re: [kernel-hardening] [PATCH v5 04/10] arm64: Add __flush_tlb_one()
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-5-tycho@docker.com> <20170812112603.GB16374@remoulade>
 <20170814163536.6njceqc3dip5lrlu@smitten>
 <20170814165047.GB23428@leverpostej>
 <20170823165842.k5lbxom45avvd7g2@smitten>
 <20170823170443.GD12567@leverpostej>
In-Reply-To: <20170823170443.GD12567@leverpostej>

--irH4NmKN7wMDrNE8J2tbOkjU4JO732xNG
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable



On 08/23/2017 07:04 PM, Mark Rutland wrote:
> On Wed, Aug 23, 2017 at 10:58:42AM -0600, Tycho Andersen wrote:
>> Hi Mark,
>>
>> On Mon, Aug 14, 2017 at 05:50:47PM +0100, Mark Rutland wrote:
>>> That said, is there any reason not to use flush_tlb_kernel_range()
>>> directly?
>>
>> So it turns out that there is a difference between __flush_tlb_one() a=
nd
>> flush_tlb_kernel_range() on x86: flush_tlb_kernel_range() flushes all =
the TLBs
>> via on_each_cpu(), where as __flush_tlb_one() only flushes the local T=
LB (which
>> I think is enough here).
>=20
> That sounds suspicious; I don't think that __flush_tlb_one() is
> sufficient.
>=20
> If you only do local TLB maintenance, then the page is left accessible
> to other CPUs via the (stale) kernel mappings. i.e. the page isn't
> exclusively mapped by userspace.

We flush all CPUs to get rid of stale entries when a new page is
allocated to userspace that was previously allocated to the kernel.
Is that the scenario you were thinking of?

=2E..Juerg


> Thanks,
> Mark.
>=20


--irH4NmKN7wMDrNE8J2tbOkjU4JO732xNG--

--A6exSVd4e9U3pOIGSQJPXxWSpn5KhIE8w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQI7BAEBCAAlBQJZpk2tHhxqdWVyZy5oYWVmbGlnZXJAY2Fub25pY2FsLmNvbQAK
CRB1TDqW+fi0jDAIEACVZxelTLbWy+NwTXC/GcrJ9nHlD6y65VQ3czwQhdSOdY6K
QfzpYKvXVbxYhf+2zqEacg3mSskZs5XU6p9wVjf6JLmNulDJLJxpNYyMYTSIm4oh
O/EBDMiQTpACQXzPWZwgOYhviepx022E37Soonp3r8PlAeRvJWXlpITP4sDEDDB6
3dVHAciqdgihh2kbtY93G/uiHAS44CBKis93IWKXLorXLuKu21DJzk2GSwLfUINq
ZdbDsbjAUWxjrOS479BZJKp4X3/zigP8vNLBF8qx6Z+6WwwYLQzQD+0hHmXTa5GL
VND4FqWU9y9U9ORwOI7cVYS+S/00PNA9jAvwm4Qm1oQUDX+bHHSuXgDK79wgAsr0
9caduoFoPlsPtF/MlfEgVOjYTWEY040IEFGJQyIZIauGUqWe/4Z1IsokuS0qIJJt
252lXFh6qfXu7A6W+fQ4kSED57gD4t/pJAT1c7MansvGl2q+W2qIC7QjWrmqSKD2
+Rk5GsIWAND0wSOz+O/2pM4KTwrDRlMutiTSlsueqEFwNmO6V+UTKLOz5nTwEAU0
uhBLctbblPLEjXpZv38H3heN8qTpwz2g98hv0hf8sa7D7FHaYuTd2/Zn2QNmhRC8
O0AiPoc6FxyJwj2VWYigF6YDZecP9FOB+C+t8pbLKaSdepfL/BF/rjU+bC6P7g==
=+9Xg
-----END PGP SIGNATURE-----

--A6exSVd4e9U3pOIGSQJPXxWSpn5KhIE8w--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
