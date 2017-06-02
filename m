Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3BBD6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 21:45:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so67269390pfd.11
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 18:45:52 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id i7si21570581pfi.233.2017.06.01.18.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 18:45:52 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id w69so10168479pfk.1
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 18:45:52 -0700 (PDT)
Date: Fri, 2 Jun 2017 09:45:49 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/vmalloc: a slight change of compare target in
 __insert_vmap_area()
Message-ID: <20170602014549.GA10347@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170524100347.8131-1-richard.weiyang@gmail.com>
 <592649CC.8090702@huawei.com>
 <20170526013639.GA10727@WeideMacBook-Pro.local>
 <59278B13.4070304@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
Content-Disposition: inline
In-Reply-To: <59278B13.4070304@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 26, 2017 at 09:55:31AM +0800, zhong jiang wrote:
>On 2017/5/26 9:36, Wei Yang wrote:
>> On Thu, May 25, 2017 at 11:04:44AM +0800, zhong jiang wrote:
>>> I hit the overlap issue, but it  is hard to reproduced. if you think it=
 is safe. and the situation
>>> is not happen. AFAIC, it is no need to add the code.
>>>
>>> if you insist on the point. Maybe VM_WARN_ON is a choice.
>>>
>> Do you have some log to show the overlap happens?
> Hi  wei
>
>cat /proc/vmallocinfo
>0xf1580000-0xf1600000  524288 raw_dump_mem_write+0x10c/0x188 phys=3D8b9010=
00 ioremap
>0xf1638000-0xf163a000    8192 mcss_pou_queue_init+0xa0/0x13c [mcss] phys=
=3Dfc614000 ioremap
>0xf528e000-0xf5292000   16384 n_tty_open+0x10/0xd0 pages=3D3 vmalloc
>0xf5000000-0xf9001000 67112960 devm_ioremap+0x38/0x70 phys=3D40000000 iore=
map

These two ranges overlap.

This is hard to say where is the problem. From the code point of view, I do=
n't
see there is possibility to allocate an overlapped range.

Which version of your kernel?
Hard to reproduce means just see once?=20

>0xfe001000-0xfe002000    4096 iotable_init+0x0/0xc phys=3D20001000 ioremap
>0xfe200000-0xfe201000    4096 iotable_init+0x0/0xc phys=3D1a000000 ioremap
>0xff100000-0xff101000    4096 iotable_init+0x0/0xc phys=3D2000a000 ioremap
>
>I hit the above issue, but the log no more useful info. it just is found b=
y accident.
>and it is hard to reprodeced. no more info can be supported for further in=
vestigation.
>therefore, it is no idea for me.=20
>
>Thanks
>zhongjinag
>

--=20
Wei Yang
Help you, Help me

--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZMMNNAAoJEKcLNpZP5cTd6C8P/ivxNxoc4T2jcQw9p+K+1ves
wYDWPdw3Vql8rP6Q4lBzY2jBrwRhSbNEaJPRniEwF3Zl31SoIdHw8KNJIboP8Pyz
tE7n8PEqeUhOOwFSDpuYRM43cnWVaAT1YAYgja6lXFcvLhZ8RG/qwVoS7zzwp3O5
xtQF/BCZWjbPD8OodnqdzXbLP1gJj1O04p+1E3GvfKkGRJ6YKf60ttWfaR98YCLM
cemsqA80lfMyfmMtl/l9O2yZO0j0Js5Qnso+k3TpyEFCQOxwzNNUl7A0Pj/zL+c5
cTRvxPPj4GrplotW9Z2pWa2HsIXfSPledX6rTC5Xk3EmvtrfCcYemvxyNlc5O320
TVX6BIFVlakCkUxB2K/km1hVtco/VD6TYtEQMb1uZr6bgp9G2dx5UIGvdTr4bxm5
2CQpJhKyLof0wce56p13IANuJCnNkRJ1i1MdJ171G8NGZZ44K+9w4fpNhbIrqIYT
Vcw2HrpBfxIKImm0tsfCi1EaY6U+dmdlvjrWvWd8iXSJmFh/uLKa8YCUpb5+sZ9F
0HdZ+gvTKMDpI5UdrTA/TUhl1chpg+Yf1rIZHeEdKYKPFlHA8ChW7DCMECtYPEv9
Baq0+kf/LWv8loTIw0B13KXHBuNtHVujYJ9zP7PwDPlf8zEGhqZt/aKmidmkHTP5
v0uHRMVauo+JULpXhc5P
=tDHq
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
