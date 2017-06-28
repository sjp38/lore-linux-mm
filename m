Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1C66B0292
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 20:16:05 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y62so41203744pfa.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:16:05 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id j33si449877pld.477.2017.06.27.17.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 17:16:04 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u36so6053608pgn.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:16:04 -0700 (PDT)
Date: Wed, 28 Jun 2017 08:16:00 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 3/4] mm/hotplug: make __add_pages() iterate on
 memory_block and split __add_section()
Message-ID: <20170628001600.GB66023@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-4-richard.weiyang@gmail.com>
 <559864c6-6ad6-297a-3094-8abecbd251b9@nvidia.com>
 <20170626235312.GE53180@WeideMacBook-Pro.local>
 <0b9439b4-0891-6596-f103-daaceaa7f404@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="DBIVS5p969aUjpLe"
Content-Disposition: inline
In-Reply-To: <0b9439b4-0891-6596-f103-daaceaa7f404@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org


--DBIVS5p969aUjpLe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 26, 2017 at 11:47:38PM -0700, John Hubbard wrote:
>On 06/26/2017 04:53 PM, Wei Yang wrote:
>> On Mon, Jun 26, 2017 at 12:50:14AM -0700, John Hubbard wrote:
>>> On 06/24/2017 07:52 PM, Wei Yang wrote:
>[...]
>>>
>>> Things have changed...the register_new_memory() routine is accepting a =
single section,
>>> but instead of registering just that section, it is registering a conta=
ining block.
>>> (That works, because apparently the approach is to make sections_per_bl=
ock =3D=3D 1,
>>> and eventually kill sections, if I am reading all this correctly.)
>>>
>>=20
>> The original function is a little confusing. Actually it tries to regist=
er a
>> memory_block while it register it for several times, on each present
>> mem_section actually.
>>=20
>> This change here will register the whole memory_block at once.
>>=20
>> You would see in next patch it will accept the start section number inst=
ead of
>> a section, while maybe more easy to understand it.
>
>Yes I saw that, and it does help, but even after that, I still thought
>we should add that "* Register an entire memory_block."  line.
>

Well, it is fine to me.


--=20
Wei Yang
Help you, Help me

--DBIVS5p969aUjpLe
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUvVAAAoJEKcLNpZP5cTdNHMP/jNuFc5i2W9ImH5ZAmaEsA3z
G7CJPYsLJWibzUgJ6bWL1k6sAD0KpoVvmv62AFsRfK57bPf9ZRUGRwva9/1K/sqU
9DjRqtE1rKlGJI75h3r2oBLizWsHm/tyjxhqL+pvGcYLqZ3JCxl9Dx/gy4dVHG09
b9GExw6GZYkUS7tr3S6Wjzpv2ik5KpRCmTh3tUPImso4O0xc07oFUb4HvbgYDLRd
Hnsg7YGhh5pfmtfzY3dQ7MeaCrUehlivYWRBk30jZGb0HhD1jTzlqJANpuUrMA8m
NLKCUqq2gCE5v3VMkidjBV5mD50HMcsxq/RfmTneItUDIv94lquNMsqDWdMN9RcQ
knJA+DsfaBn8uVz58UkD585pI9RMSVAlVFGfX2ovwPpzxHOKOtf9FW48vgeOju0r
5ARsC7S1ub9e2iEyAxTXhwurzCnkee3Ad04Hdtr0PaHWL1vbTG5Qz8HpckveM0gq
OqboRo9Ndu6MApTrHIotIMmlplT19uGeS4oFHmtEtSiPqUygkkl3Yf6G89IkE8zO
tly3kDd4eqCn48QmESF0M3rEw0h9mMzMVIwvqm2E3LlZZgK8812EFNTx4RPO6T61
Z1djqFKg9S8jTUweQqom5ISUPgXUnISxXWZO9o4zk1cS0dUNSN4YDDQtLp87gvwe
EACDR3dIXJdc1kEeTgz+
=67h1
-----END PGP SIGNATURE-----

--DBIVS5p969aUjpLe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
