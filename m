Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 937A16B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 19:27:06 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so99154851pab.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 16:27:06 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id rq7si24586404pab.73.2015.10.22.16.27.05
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 16:27:05 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] mm: Introduce kernelcore=reliable option
Date: Thu, 22 Oct 2015 23:26:49 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B5C7AE@ORSMSX114.amr.corp.intel.com>
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
 <5628B427.3050403@jp.fujitsu.com>
In-Reply-To: <5628B427.3050403@jp.fujitsu.com>
Content-Language: en-US
Content-Type: multipart/mixed;
	boundary="_002_3908561D78D1C84285E8C5FCA982C28F32B5C7AEORSMSX114amrcor_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

--_002_3908561D78D1C84285E8C5FCA982C28F32B5C7AEORSMSX114amrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> I think /proc/zoneinfo can show detailed numbers per zone. Do we need som=
e for meminfo ?

I wrote a little script (attached) to summarize /proc/zoneinfo ... on my sy=
stem it says

$ zoneinfo
Node          Normal         Movable             DMA           DMA32=20
   0            0.00       103020.07            8.94         1554.46=20
   1         9284.54        89870.43                                =20
   2         9626.33        94050.09                                =20
   3         9602.82        93650.04   =20

Not sure why I have zero Normal memory free on node0.  The sum of all those
free counts is 410667.72 MB ... which is close enough to the boot time mess=
age
showing the amount of mirror/total memory:

[    0.000000] efi: Memory: 80979/420096M mirrored memory

but a fair amount of the 80G of mirrored memory seems to have been miscount=
ed
as Movable instead of Normal. Perhaps this is because I have two blocks of =
mirrored
memory on each node and the movable zone code doesn't expect that?

-Tony                            =20




--_002_3908561D78D1C84285E8C5FCA982C28F32B5C7AEORSMSX114amrcor_
Content-Type: application/octet-stream; name="zoneinfo"
Content-Description: zoneinfo
Content-Disposition: attachment; filename="zoneinfo"; size=485;
	creation-date="Thu, 22 Oct 2015 23:09:04 GMT";
	modification-date="Thu, 22 Oct 2015 23:08:26 GMT"
Content-Transfer-Encoding: base64

IyEvYmluL2Jhc2gKCmF3ayAnCiQxID09ICJOb2RlIiB7Cgl0aGlzbm9kZSA9ICQyICsgMAoJdGhp
c3pvbmUgPSAkNAoJYWxsbm9kZXNbdGhpc25vZGVdID0gdGhpc25vZGUKCXpuYW1lc1t0aGlzem9u
ZV0gPSAxCn0KJDEgPT0gInBhZ2VzIiAmJiAkMiA9PSAiZnJlZSIgewoJbmZyZWVbdGhpc25vZGUg
IiwiIHRoaXN6b25lXSA9ICQzCn0KRU5EIHsKCXByaW50ZigiTm9kZSAiKQoJZm9yICh6IGluIHpu
YW1lcykKCQlwcmludGYoIiUxNXMgIiwgeikKCXByaW50ZigiXG4iKQoKCWZvciAobiBpbiBhbGxu
b2RlcykgewoJCXByaW50ZigiJTRkICIsIG4pCgkJZm9yICh6IGluIHpuYW1lcykgewoJCQlpZHgg
PSBuICIsIiB6CgkJCWlmIChpZHggaW4gbmZyZWUpCgkJCQlwcmludGYoIiUxNS4yZiAiLCBuZnJl
ZVtpZHhdLzI1Ni4wKQoJCQllbHNlCgkJCQlwcmludGYoIiUxNXMgIiwgIiIpCgkJfQoJCXByaW50
ZigiXG4iKQoJfQp9JyAvcHJvYy96b25laW5mbwo=

--_002_3908561D78D1C84285E8C5FCA982C28F32B5C7AEORSMSX114amrcor_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
