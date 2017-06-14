Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B64CF6B0292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 05:12:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u8so100073621pgo.11
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:12:09 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id a33si231949plc.382.2017.06.14.02.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 02:12:09 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y7so25806966pfd.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:12:09 -0700 (PDT)
Date: Wed, 14 Jun 2017 17:12:06 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 04/14] mm, memory_hotplug: get rid of
 is_zone_device_section
Message-ID: <20170614091206.GA15768@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170515085827.16474-1-mhocko@kernel.org>
 <20170515085827.16474-5-mhocko@kernel.org>
 <CADZGycawwb8FBqj=4g3NThvT-uKREbaH+kYAxvXRrW1Vd5wsvA@mail.gmail.com>
 <20170614061259.GB14009@WeideMBP.lan>
 <20170614063206.GF6045@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Content-Disposition: inline
In-Reply-To: <20170614063206.GF6045@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 14, 2017 at 08:32:06AM +0200, Michal Hocko wrote:
>On Wed 14-06-17 14:12:59, Wei Yang wrote:
>[...]
>> Hi, Michal
>>=20
>> Not sure you missed this one or you think this is fine.
>>=20
>> Hmm... this will not happen since we must offline a whole memory_block?
>
>yes
>
>> So the memory_hotplug/unplug unit is memory_block instead of mem_section?
>
>yes.

If this is true, the check_hotplug_memory_range() should be fixed too.

This function just makes sure the range is section aligned, instead of
memory_block aligned.

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZQP3mAAoJEKcLNpZP5cTd6mcP/joHK9/njSIGJRCRitDOU9xX
aKGv8lEfZmG74NinxghfW8gxTwajggfcUAy9Z/dqp3xSdV4wZgozESiDB9WCSj5m
ZWDqtCIJab+v7GdkOMylznP8eoRbBZC/fdUse4IVybQN6KUZDN5ZUWqOLxs9krup
g2vVry4PpzJ9sFegYrBfnh8tUSu2ixSLFrqe0Kg76Oz88hgSjcgRNoWtGiZmLqaX
A6UEuMi18Ec19Xj5f8/LJLUU+bdYoiMY+x+5OFq47PUdT3K8gdzLh6aHCCWENR4N
B6FysQngjOX6k0Trzf1GZZ06ICWqjfk6fFv4F5dSrq87pzX/DGQ4lMB2jNCMo36q
NcmPaelHLmBJcUIlKf6uetVRnSmsKeYDGZwK2owHQ+Fe0KNKz9WlgoY6iBgUgV3J
ewo829HLXVfBEXI0svcAo1TQaoEeMVGLRpBAg6HrHOxGLfBDfTMw4MfPGgIKhoZA
1v2PpO6umgZNlUKGnK7uTbuXlrsgILYrwyzLN0tz8l1kEuR0r7u40JcWml3l6enC
gdrWf88hNAZeEYTygbp8OUJ+ciCQ86pi8VW9thGYE4HCSDhabzITx4fZbycCfn/f
2T2aylqaCPK8qKGhTBCign66+lfGuPpHUBNjOEAbVHOLBT3S1MJmTfxybUBhjq9L
hsp4h1l3ijuqTf1qO8IT
=Ohwl
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
