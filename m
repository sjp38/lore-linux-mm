Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1665F6B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 23:06:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a7so69889589pgn.7
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 20:06:59 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 3si9156545plr.366.2017.06.05.20.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 20:06:58 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id w69so22865731pfk.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 20:06:58 -0700 (PDT)
Date: Tue, 6 Jun 2017 11:06:56 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Trivial typo fix.
Message-ID: <20170606030656.GB2259@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170605014350.1973-1-richard.weiyang@gmail.com>
 <20170605062248.GC9248@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="GID0FwUMdk1T2AWN"
Content-Disposition: inline
In-Reply-To: <20170605062248.GC9248@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 05, 2017 at 08:22:48AM +0200, Michal Hocko wrote:
>On Mon 05-06-17 09:43:50, Wei Yang wrote:
>> Looks there is no word "blamo", and it should be "blame".
>>=20
>> This patch just fix the typo.
>
>Well, I do not think this is a typo. blamo has a slang meaning which I
>believe was intentional. Besides that, why would you want to fix this
>anyway. Is this something that you would grep for?
>

Oh, I thought it was wrong, so I did this change.

>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/page_alloc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 07efbc3a8656..9ce765e6fe2f 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3214,7 +3214,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int=
 order,
>>  	if (gfp_mask & __GFP_THISNODE)
>>  		goto out;
>> =20
>> -	/* Exhausted what can be done so it's blamo time */
>> +	/* Exhausted what can be done so it's blame time */
>>  	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>>  		*did_some_progress =3D 1;
>> =20
>> --=20
>> 2.11.0
>>=20
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--GID0FwUMdk1T2AWN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZNhxQAAoJEKcLNpZP5cTdUmEP/2OBLLLKR2n5p12W31g5d98n
BUQnxdQu211ohntBkGczPa2ZKDixYhsBK+zfGRUkVyF92lDQvcpHNkhMlTvORjWy
zOAaS+09v3+tVIboaZNWgyBTtGsAMnIC/4k1u6IEQoJlSTCurbxl2r2UX8DxQE+0
DGaQCSOiKB8VKeZJ1AJTd9uAQKWeBVreQiRB13yQ9Cmz24WoEp49+b5lkjisTvdH
w4iZKuXMhtcYF1syCqfI2gPpuX8F7MR5KfLHlunMgMlfLYWuuiTZkEIM8DInteWY
2FkvDacN0AMKiGMGOereoPY2s+ZQGMe2A8Jjd8daEzYuh8fnu8Sb8H3wuXL9q1X7
GxNX+Ni5zPVNAugevOv9SsA9BkxaXlbtwlpGodSmVQZ0jyzbCj/pdoJFw7p1sQPq
PmqR3S+d81o+y9fytHYxQ/nJVuvwhMd4qk036HLZ1XEJczkjg9gsTgxILxUZZY1+
bR6gJupDBW0iYeoSG2R5HBBLUyGr2iL/DR7PZEwuoQjINJEb6DNiuAXEVpk7MHBB
TP/A/1YySAtFonh09uoN1Z2pyJ6jqgw9hatE2kBP3u4RKnQFgC10h3r06xK5S81F
pB+DW+twKsc0N2oEg290GgmSuQ/1hB6XXLDZqgYveR9OTWbH6pV6RLw77gZ4Iiqy
6QUJmPIRnUTrBs+90Wap
=bEZB
-----END PGP SIGNATURE-----

--GID0FwUMdk1T2AWN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
