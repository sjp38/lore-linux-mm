Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAEF16B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 22:29:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e7so96718519pfk.9
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 19:29:04 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id y2si1267053pli.466.2017.06.02.19.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 19:29:03 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id f127so3470314pgc.2
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 19:29:03 -0700 (PDT)
Date: Sat, 3 Jun 2017 10:28:58 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/vmalloc: a slight change of compare target in
 __insert_vmap_area()
Message-ID: <20170603022858.GB11080@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170524100347.8131-1-richard.weiyang@gmail.com>
 <592649CC.8090702@huawei.com>
 <20170526013639.GA10727@WeideMacBook-Pro.local>
 <59278B13.4070304@huawei.com>
 <20170602014549.GA10347@WeideMBP.lan>
 <5930CCBE.4030802@huawei.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="pvezYHf7grwyp3Bc"
Content-Disposition: inline
In-Reply-To: <5930CCBE.4030802@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--pvezYHf7grwyp3Bc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 02, 2017 at 10:26:06AM +0800, zhong jiang wrote:
>On 2017/6/2 9:45, Wei Yang wrote:
>> On Fri, May 26, 2017 at 09:55:31AM +0800, zhong jiang wrote:
>>> On 2017/5/26 9:36, Wei Yang wrote:
>>>> On Thu, May 25, 2017 at 11:04:44AM +0800, zhong jiang wrote:
>>>>> I hit the overlap issue, but it  is hard to reproduced. if you think =
it is safe. and the situation
>>>>> is not happen. AFAIC, it is no need to add the code.
>>>>>
>>>>> if you insist on the point. Maybe VM_WARN_ON is a choice.
>>>>>
>>>> Do you have some log to show the overlap happens?
>>> Hi  wei
>>>
>>> cat /proc/vmallocinfo
>>> 0xf1580000-0xf1600000  524288 raw_dump_mem_write+0x10c/0x188 phys=3D8b9=
01000 ioremap
>>> 0xf1638000-0xf163a000    8192 mcss_pou_queue_init+0xa0/0x13c [mcss] phy=
s=3Dfc614000 ioremap
>>> 0xf528e000-0xf5292000   16384 n_tty_open+0x10/0xd0 pages=3D3 vmalloc
>>> 0xf5000000-0xf9001000 67112960 devm_ioremap+0x38/0x70 phys=3D40000000 i=
oremap
>> These two ranges overlap.
>>
>> This is hard to say where is the problem. From the code point of view, I=
 don't
>> see there is possibility to allocate an overlapped range.
>>
>> Which version of your kernel?
>> Hard to reproduce means just see once?=20
>  yes, just once.  I have also no see any problem from the code.   The ker=
nel version is linux 4.1.
> but That indeed exist.=20
>

This is really interesting. While without reproducing the behavior, it is
really costly to debug in the code.

I took a look into my own /proc/vmallocinfo, there are around hundred entri=
es.
Currently, I don't have a clue to dive into the issue.

> Thanks
>zhongjiang
>>> 0xfe001000-0xfe002000    4096 iotable_init+0x0/0xc phys=3D20001000 iore=
map
>>> 0xfe200000-0xfe201000    4096 iotable_init+0x0/0xc phys=3D1a000000 iore=
map
>>> 0xff100000-0xff101000    4096 iotable_init+0x0/0xc phys=3D2000a000 iore=
map
>>>
>>> I hit the above issue, but the log no more useful info. it just is foun=
d by accident.
>>> and it is hard to reprodeced. no more info can be supported for further=
 investigation.
>>> therefore, it is no idea for me.=20
>>>
>>> Thanks
>>> zhongjinag
>>>
>

--=20
Wei Yang
Help you, Help me

--pvezYHf7grwyp3Bc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZMh7qAAoJEKcLNpZP5cTdYZ0P/RTqqD0VGv88wZBuRuXMoqVO
nH2bFA9ITSesXvDGYnFVWlno9UZzHhz/4F04E6dyj8ivXOYMyIzC1A81iaKqXhE5
OZZzj5+D7j0ARyNd7n1gQKypGUVaNJDHw4vcM3YWghsUn+t4gcLC1c5iJ8+EXoF5
36CZHQoFOq8hvw2UYvl/Ois0BtWtyCC3rqwWc1RXvuScZ/i4bpY1XdqwReb37swP
PLea/DpnLGxgb/eRryC38WaeVs7VlwzzYk9L4/kFvJQ95zVdEsiEt+InVuAjfQNW
z9CzuU0QtVqJ1HPrCfakEmpqeUF8u0EEfPAMQVebEDOLmUSLAI8eod/kDcbXqUML
HqtOTT5+t/BsFth04vPApHGeyz8q9eFxd43D6W64nlD79+EpuKiBgrsY4cwiZeRI
s/ZWrrrUPa6Fh/BlEgnoLNsk3i/Nmb9AdxwOfYbyKhTZj+1zHJd0I+d7HPuFXhuU
vyi1M3YN3+dlycmu2YwxIluKiIMoX+LtdUnVilh1U7fkQO3mlbVY2PPrxm4FqEqy
QpxKbpPLV6L+TK2q9hNZEnj9VRxBNcrUG1Ejx9RuWMaMSx7Pngh8ZL3WOHpKal/P
up6+ifK3XySe7HWqIHfeIUd9kAskqgyIQFY35DGu5l7GkkRP3eykZl/m9WCiGpZG
k5TBFKzoSM/2UTvVAQ1L
=pXHc
-----END PGP SIGNATURE-----

--pvezYHf7grwyp3Bc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
