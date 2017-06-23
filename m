Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15A1C6B02C3
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 21:37:26 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d191so31171168pga.15
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:37:26 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id j19si2412956pgn.452.2017.06.22.18.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 18:37:25 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id f127so4436765pgc.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:37:25 -0700 (PDT)
Date: Fri, 23 Jun 2017 09:37:22 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: do not assume ZONE_NORMAL is
 default kernel zone
Message-ID: <20170623013722.GA14321@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170601083746.4924-1-mhocko@kernel.org>
 <20170601083746.4924-3-mhocko@kernel.org>
 <20170622023243.GA1242@WeideMacBook-Pro.local>
 <20170622181656.GB19563@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Content-Disposition: inline
In-Reply-To: <20170622181656.GB19563@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 22, 2017 at 08:16:57PM +0200, Michal Hocko wrote:
>>=20
>> Hmm... a corner case jumped into my mind which may invalidate this
>> calculation.
>>=20
>> The case is:
>>=20
>>=20
>>        Zone:         | DMA   | DMA32      | NORMAL       |
>>                      v       v            v              v
>>       =20
>>        Phy mem:      [           ]     [                  ]
>>       =20
>>                      ^           ^     ^                  ^
>>        Node:         |   Node0   |     |      Node1       |
>>                              A   B     C  D
>>=20
>>=20
>> The key point is
>> 1. There is a hole between Node0 and Node1
>> 2. The hole sits in a non-normal zone
>>=20
>> Let's mark the boundary as A, B, C, D. Then we would have
>> node0->zone[dma21] =3D [A, B]
>> node1->zone[dma32] =3D [C, D]
>>=20
>> If we want to hotplug a range in [B, C] on node0, it looks not that bad.=
 While
>> if we want to hotplug a range in [B, C] on node1, it will introduce the
>> overlapped zone. Because the range [B, C] intersects none of the existing
>> zones on node1.
>>=20
>> Do you think this is possible?
>
>Yes, it is possible. I would be much more more surprised if it was real
>as well. Fixing that would require to use arch_zone_{lowest,highest}_possi=
ble_pfn
>which is not available after init section disappears and I am not even
>sure we should care. I would rather wait for a real life example of such
>a configuration to fix it.

Yep, not easy to fix, so wait for real case.

Or possible to add a line in commit log?

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZTHDSAAoJEKcLNpZP5cTdzSAQAIZi1ymbkTayVdr3OA9yJjN2
zT1clCjZwMPobT21HbM2Im4NiBzUvk7fTfqEq6Rbc5eqUUgpa9bLwpr3wVnOmWGE
3Ge7QGRkFwGSb/0zxThCU3bPZayt/Dv4ejhyfla2IGz6Goy0jRLHzU5wq0mpo5zH
eNQCLRMkETsOVt7rskIHq4K/aQhqvn51PGrDRN0t4s3T8qsy2NSpGwBK2A5SMb2Y
XOKWiF6U8V3qyzC8SNHPP2j9WLQQZBLRimQRToazvXQmpBS6vi9ZVWFtmI/QwGZA
pIKhO8WHrrh9p+uahIS+8PgvRqKpt6N1AltlmLYkmFctL5PpFKYVq2fatWUQovXT
TVJHJAFUbmJ7UtyrCz5kHE9JjOMpWv3RWWpoAkh49oNmlZxrt2XVvt/IqTOSvvoW
A9wusQBy8u5MUSoc4CcA9zb2Hsvbju3L4t3STWYJkMQg28iWuXQxUkmHn8JLWV9q
7GOLGbBlGWeMf+KWOyfpPack8n0cdvTG5ob56ch+4tkQX9ZnBe8Oys5OnFuo8rCN
VPdGRVPMpaw4bEq3r/IXi70YhzYCC2YjPI0X7GRQVULsLFDeS4jxAYfnvNUULMx1
Mw8FLaD9YoifiQx8UuBG48MUyIX6ga2hQRE7yd2gsAGM1cFYa9bN4l21DY3PjIDg
udNEicDzzMSMboUQnqVx
=KOYq
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
