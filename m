Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA4976B0279
	for <linux-mm@kvack.org>; Mon, 22 May 2017 23:27:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so150298482pff.13
        for <linux-mm@kvack.org>; Mon, 22 May 2017 20:27:08 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 71si19328769pfi.413.2017.05.22.20.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 20:27:08 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id w69so24271866pfk.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 20:27:08 -0700 (PDT)
Date: Tue, 23 May 2017 11:27:05 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
Message-ID: <20170523032705.GA4275@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
 <20170518090636.GA25471@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="cWoXeonUoKmBZSoM"
Content-Disposition: inline
In-Reply-To: <20170518090636.GA25471@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 18, 2017 at 11:06:37AM +0200, Michal Hocko wrote:
>On Wed 17-05-17 22:11:40, Wei Yang wrote:
>> This patch serial could be divided into two parts.
>>=20
>> First three patches refine and adds slab sysfs.
>> Second three patches rename slab sysfs.
>>=20
>> 1. Refine slab sysfs
>>=20
>> There are four level slabs:
>>=20
>>     CPU
>>     CPU_PARTIAL
>>     PARTIAL
>>     FULL
>>=20
>> And in sysfs, it use show_slab_objects() and cpu_partial_slabs_show() to
>> reflect the statistics.
>>=20
>> In patch 2, it splits some function in show_slab_objects() which makes s=
ure
>> only cpu_partial_slabs_show() covers statistics for CPU_PARTIAL slabs.
>>=20
>> After doing so, it would be more clear that show_slab_objects() has tota=
lly 9
>> statistic combinations for three level of slabs. Each slab has three cas=
es
>> statistic.
>>=20
>>     slabs
>>     objects
>>     total_objects
>>=20
>> And when we look at current implementation, some of them are missing. So=
 patch
>> 2 & 3 add them up.
>>=20
>> 2. Rename sysfs
>>=20
>> The slab statistics in sysfs are
>>=20
>>     slabs
>>     objects
>>     total_objects
>>     cpu_slabs
>>     partial
>>     partial_objects
>>     cpu_partial_slabs
>>=20
>> which is a little bit hard for users to understand. The second three pat=
ches
>> rename sysfs file in this pattern.
>>=20
>>     xxx_slabs[[_total]_objects]
>>=20
>> Finally it looks Like
>>=20
>>     slabs
>>     slabs_objects
>>     slabs_total_objects
>>     cpu_slabs
>>     cpu_slabs_objects
>>     cpu_slabs_total_objects
>>     partial_slabs
>>     partial_slabs_objects
>>     partial_slabs_total_objects
>>     cpu_partial_slabs
>
>_Why_ do we need all this?

To have a clear statistics for each slab level.

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--cWoXeonUoKmBZSoM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZI6wJAAoJEKcLNpZP5cTdXbQQAIFAoCtbpbBM3dIIf/BfMjg6
nUzmhsgcQz85USl558rXETQ2gSxsRhQx8ykF2gTQi13zTYkj6OaQSBV2bcibvP7h
+clRc89TOnr3hdCUzWvU0nEVWo85V0OhNKdTSxvwU/uL41EqGX+2RqVuTmWZgurD
I1l7Th8WqySqMkWuTb6r9+5gcfImxsU+sfLpHY57c81xFGpFMcmtHyB16oqgfvwq
kvoXbhWYJRBFRebsu1AzfnVjhFTDs9ktgATTkEzC4bhQJMWai1+2UYpLffegN+T0
9YuRvLXbu9jOPODXuapZxpXK5+c6q9Yp6hXuP8D8yPwRDXhVacLCsLh7me92QaaT
r9Ka4EnG4j/jGjO9B4nbbeLzC9AYf7iVkxeJj0IrWVsxxIEtZll8DxSYwqVbYimg
EPMKvpMUio89NYru23hURrkH4SHAJpkNMaVZTzrnOaFhdY4mD9q4GC6y6FdgEFHx
T0O8yzXCWgLq+MsNoQS9GWHbprsaSK7kryWvYb2TnopM+lNAXMz2eQLGBQZBszbN
bWVPRga0x2qGU7MzzGNJETZihkjnbIcV2xOM3BbLHePoBEPzE08fEORjQOO4s5fF
mSWbLeTEJT4zNzIN0DWmMSgpOsMJiriXmTidMwwK9mRL0SkvClCY+TNR8tuMjpUx
lPO4/6gPPx8CGVrSIEMT
=O+Fb
-----END PGP SIGNATURE-----

--cWoXeonUoKmBZSoM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
