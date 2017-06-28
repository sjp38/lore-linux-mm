Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A5D956B0292
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 20:11:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f127so42012905pgc.10
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:11:44 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id s4si396260pgs.363.2017.06.27.17.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 17:11:43 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id u62so6061542pgb.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:11:43 -0700 (PDT)
Date: Wed, 28 Jun 2017 08:11:39 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 2/4] mm/hotplug: walk_memroy_range on memory_block uit
Message-ID: <20170628001139.GA66023@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-3-richard.weiyang@gmail.com>
 <eeb06db0-086a-29f9-306d-a702984594df@nvidia.com>
 <20170626234038.GD53180@WeideMacBook-Pro.local>
 <3ad226f5-92f1-352a-d7ee-159eef5d60e3@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
In-Reply-To: <3ad226f5-92f1-352a-d7ee-159eef5d60e3@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 26, 2017 at 11:59:52PM -0700, John Hubbard wrote:
>On 06/26/2017 04:40 PM, Wei Yang wrote:
>> On Mon, Jun 26, 2017 at 12:32:40AM -0700, John Hubbard wrote:
>>> On 06/24/2017 07:52 PM, Wei Yang wrote:
>[...]
>>>
>>> Why is it safe to assume no holes in the memory range? (Maybe Michal's=
=20
>>> patch already covered this and I haven't got that far yet?)
>>>
>>> The documentation for this routine says that it walks through all
>>> present memory sections in the range, so it seems like this patch
>>> breaks that.
>>>
>>=20
>> Hmm... it is a little bit hard to describe.
>>=20
>> First the documentation of the function is a little misleading. When you=
 look
>> at the code, it call the "func" only once for a memory_block, not for ev=
ery
>> present mem_section as it says. So have some memory in the memory_block =
would
>> meet the requirement.
>>=20
>> Second, after the check in patch 1, it is for sure the range is memory_b=
lock
>> aligned, which means it must have some memory in that memory_block. It w=
ould
>> be strange if someone claim to add a memory range but with no real memor=
y.
>>=20
>> This is why I remove the check here.
>
>OK. In that case, it seems like we should update the function documentation
>to match. Something like this, maybe? :
>
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index bdaafcf46f49..d36b2f4eaf39 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -1872,14 +1872,14 @@ int offline_pages(unsigned long start_pfn, unsigne=
d long nr_pages)
> #endif /* CONFIG_MEMORY_HOTREMOVE */
>=20
> /**
>- * walk_memory_range - walks through all mem sections in [start_pfn, end_=
pfn)
>+ * walk_memory_range - walks through all mem blocks in [start_pfn, end_pf=
n)
>  * @start_pfn: start pfn of the memory range
>  * @end_pfn: end pfn of the memory range
>  * @arg: argument passed to func
>- * @func: callback for each memory section walked
>+ * @func: callback for each memory block walked
>  *
>- * This function walks through all present mem sections in range
>- * [start_pfn, end_pfn) and call func on each mem section.
>+ * This function walks through all mem blocks in the range
>+ * [start_pfn, end_pfn) and calls func on each mem block.
>  *
>  * Returns the return value of func.
>  */
>

Yes, I have changed this in my repo.

>
>thanks,
>john h

--=20
Wei Yang
Help you, Help me

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUvQ7AAoJEKcLNpZP5cTdkB4P/1dW3PJKYXiEPdVAyomyYkhx
qVGq8L/nDQKEzHwJnB9BfEiABxmc+Tna5Umq63+2M2ERjYVE4YhDks7G/u+yXgOz
ZTS3gAlyZ2uBcB+NfD6eUfIcEqe4bjZzaQWFH93ehx/45AzCzjVLGdC19U4sxNX4
KIS4NYhz56CX6QVrxFoOKksNFmvdNXRJfaASIvXnQw5SsEKPj0CKke9KSvIYGGZQ
ZvMfPjioZGOTeW+jEcuFks8WBrLTOTR/oZcJUTc1Frd/1Ed5pxE2YfcDotT1pfNo
cNc4P39zj4dcMaM3mfr+kh92/vm/OdeN4Z3kLxMv9NByJYvxEe38sxXWb0r6fCNM
E+V6twaa6uHalPqvt+ylV/eN+yxNb6hPm3MN885evsqbY78ibiIp0Ox8xWxpeaNL
Zm4Bg9sStICqHybk8wE0UG+i529h4SHKd7gXfT9pzV+QKsllPsFiIyO+cn+ohZLS
E8jAYQY0TaVJv+32v5A2xOQiI6ehi3q16wfOJyDIqxLIjPEZcNfty1ytiDtOYuz2
0fL0bxGVl5nZ40xvg+zrs5LjtWl5I+cSBme0H7BeOipPtxTzLqvBagU4dgA9Zebx
kpXE4SdtxczHNikMtaljpFNsYnDY7wQXtMjJiEL9ufWNoP6RnJBtCfZmr7fOANUL
aOm8RnSEkems42F5JeKa
=9Q1k
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
