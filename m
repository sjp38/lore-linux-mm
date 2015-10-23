Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA066B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 21:44:33 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so26008772igb.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 18:44:33 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id lp5si1239011igb.77.2015.10.22.18.44.32
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 18:44:32 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH] mm: Introduce kernelcore=reliable option
Date: Fri, 23 Oct 2015 01:44:31 +0000
Message-ID: <322B7BFA-08FE-4A8F-B54C-86901BDB7CBD@intel.com>
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
 <5628B427.3050403@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5C7AE@ORSMSX114.amr.corp.intel.com>,<E86EADE93E2D054CBCD4E708C38D364A54280C26@G01JPEXMBYT01>
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A54280C26@G01JPEXMBYT01>
Content-Language: en-US
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

First part of each memory controller. I have two memory controllers on each=
 node

Sent from my iPhone

> On Oct 22, 2015, at 18:01, Izumi, Taku <izumi.taku@jp.fujitsu.com> wrote:
>=20
> Dear Tony,
>=20
>> -----Original Message-----
>> From: Luck, Tony [mailto:tony.luck@intel.com]
>> Sent: Friday, October 23, 2015 8:27 AM
>> To: Kamezawa, Hiroyuki/=1B$B55_7=1B(B =1B$B42G7=1B(B; Izumi, Taku/=1B$B@=
t=1B(B =1B$BBs=1B(B; linux-kernel@vger.kernel.org; linux-mm@kvack.org
>> Cc: qiuxishi@huawei.com; mel@csn.ul.ie; akpm@linux-foundation.org; Hanse=
n, Dave; matt@codeblueprint.co.uk
>> Subject: RE: [PATCH] mm: Introduce kernelcore=3Dreliable option
>>=20
>>> I think /proc/zoneinfo can show detailed numbers per zone. Do we need s=
ome for meminfo ?
>>=20
>> I wrote a little script (attached) to summarize /proc/zoneinfo ... on my=
 system it says
>>=20
>> $ zoneinfo
>> Node          Normal         Movable             DMA           DMA32
>>   0            0.00       103020.07            8.94         1554.46
>>   1         9284.54        89870.43
>>   2         9626.33        94050.09
>>   3         9602.82        93650.04
>>=20
>> Not sure why I have zero Normal memory free on node0.  The sum of all th=
ose
>> free counts is 410667.72 MB ... which is close enough to the boot time m=
essage
>> showing the amount of mirror/total memory:
>>=20
>> [    0.000000] efi: Memory: 80979/420096M mirrored memory
>>=20
>> but a fair amount of the 80G of mirrored memory seems to have been misco=
unted
>> as Movable instead of Normal. Perhaps this is because I have two blocks =
of mirrored
>> memory on each node and the movable zone code doesn't expect that?
>=20
> You were saying that OS view of memory of node is something like the foll=
owing ?
>=20
>    Node X:  |MMMMMM------MMMMMM--------| =20
>       (legend) M: mirrored  -: not mirrrored
>=20
> If so, is this a real Box's configuration?
> Sorry, I haven't got a real Address Range Mirror capable boxes yet ...
> I thought mirroring range is concatenated at the first part of each node.
>=20
> Sincerely,
> Taku Izumi
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
