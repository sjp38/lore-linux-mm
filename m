Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B12C6B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 04:37:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g7so27677766pgp.1
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:37:28 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id c83si1767122pfd.95.2017.07.07.01.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 01:37:27 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id d193so3284483pgc.2
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:37:27 -0700 (PDT)
Date: Fri, 7 Jul 2017 16:37:23 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove zone restrictions
Message-ID: <20170707083723.GA19821@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170629073509.623-1-mhocko@kernel.org>
 <20170629073509.623-3-mhocko@kernel.org>
 <CADZGycaXs-TsVN2xy_rpFE_ML5_rs=iYN6ZQZsAfjTVHFyLyEQ@mail.gmail.com>
 <20170630083926.GA22923@dhcp22.suse.cz>
 <CADZGyca1-CzaHoR-==DN4kK_YrwmMVnKvowUv-5M4GQP7ZYubg@mail.gmail.com>
 <20170630095545.GF22917@dhcp22.suse.cz>
 <20170630110118.GG22917@dhcp22.suse.cz>
 <20170705231649.GA10155@WeideMacBook-Pro.local>
 <20170706065649.GC29724@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
In-Reply-To: <20170706065649.GC29724@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Xishi Qiu <qiuxishi@huawei.com>, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 06, 2017 at 08:56:50AM +0200, Michal Hocko wrote:
>> Below is a result with a little changed kernel to show the start_pfn alw=
ays.
>> The sequence is:
>> 1. bootup
>>=20
>> Node 0, zone  Movable
>>         spanned  65536
>> 	present  0
>> 	managed  0
>>   start_pfn:           0
>>=20
>> 2. online movable 2 continuous memory_blocks
>>=20
>> Node 0, zone  Movable
>>         spanned  65536
>> 	present  65536
>> 	managed  65536
>>   start_pfn:           1310720
>>=20
>> 3. offline 2nd memory_blocks
>>=20
>> Node 0, zone  Movable
>>         spanned  65536
>> 	present  32768
>> 	managed  32768
>>   start_pfn:           1310720
>>=20
>> 4. offline 1st memory_blocks
>>=20
>> Node 0, zone  Movable
>>         spanned  65536
>> 	present  0
>> 	managed  0
>>   start_pfn:           1310720
>>=20
>> So I am not sure this is still clearly defined?
>
>Could you be more specific what is not clearly defined? You have
>offlined all online memory blocks so present/managed is 0 while the
>spanned is unchanged because the zone is still defined in range
>[1310720, 1376256].
>

The zone is empty after remove these two memory blocks, while we still think
it is defined in range [1310720, 1376256]. This is what I want to point.

>I also do not see how this is related with the discussed patch as there
>is no zone interleaving involved.

I had a patch which fix the behavior, which means we can make sure the zone=
 is
empty after remove these two memory blocks. As you mentioned in the reply,
http://www.spinics.net/lists/linux-mm/msg130230.html, I thought you would h=
ave
this fixed in this cycle. While it looks we will still have this behavior in
this cycle and looks no intend to fix this?

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--AqsLC8rIMeq19msA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZX0hDAAoJEKcLNpZP5cTdizQP+gM9VAADXkT08cquUGeUdNDL
YF7rIkILCBmPOOg9Y9xrHMhdQLgzxIvQcs6Sv5vXx7Kj24LzwVlIrRoJUH+2P/yR
TGKFccZ9N0RZ8V6YvPMoT5HBVgaLENSQYCxYkJvcz83uu/9MrnvcYCh/6qn2vr+Y
djgy564P1bI+lchNAeilxwkqedEvzuJ67A/wXR7eLyj3G3Gpq/H7KhWXyiaZ/qCk
NTdoACDnn9LfjqEad4IKy1+1yVyRyX3ObVIRaO+YyKA7pHKDTNJFeaa8+rHmnzXy
lK5W9w3Xes9kUk8Rxj+KxZv/VP835zd+jVQeF9Iyk5dC0P3L8XiI9pF/7E7sOTxW
neLkKu8RRUMzpUyjeDD4P/wWoKulKVrhs3JlnWsdWhxi5bB0FsaLdOyoqOeWdXEc
qKeAvx9zvEMtTQRz9yVlHiBhHSci/TBybgdOJjweRbvbjINPHMS9tC9OVMP3pr7x
ODivoQVmSXLuCcVN5HteKBZl2Z+aIexAAdbNgk/X30FATEGFokColNo7xuVZr2ez
44WmpAOYu7D+v0xp4nGhMUltvrIc0Dd6xC9iMTeJR6CTlXiHqO+HQroUwWO7/u/F
FTd+UUyJPkPXQqGtEouUlFQYg7XO3DRbAt+2+CRvZBtOR+wBsM7YMIUyCjfXXqiV
z856sFdHjIQd/KwbA98Y
=dasa
-----END PGP SIGNATURE-----

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
