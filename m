Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EBFE26B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 21:01:20 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so101269149pab.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 18:01:20 -0700 (PDT)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id fg5si25178724pbc.5.2015.10.22.18.01.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 18:01:20 -0700 (PDT)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id C274EAC01DA
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 10:01:14 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH] mm: Introduce kernelcore=reliable option
Date: Fri, 23 Oct 2015 01:01:12 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54280C26@G01JPEXMBYT01>
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
 <5628B427.3050403@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5C7AE@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32B5C7AE@ORSMSX114.amr.corp.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

 Dear Tony,

> -----Original Message-----
> From: Luck, Tony [mailto:tony.luck@intel.com]
> Sent: Friday, October 23, 2015 8:27 AM
> To: Kamezawa, Hiroyuki/亀澤 寛之; Izumi, Taku/泉 拓; linux-kernel@vger.kernel.org; linux-mm@kvack.org
> Cc: qiuxishi@huawei.com; mel@csn.ul.ie; akpm@linux-foundation.org; Hansen, Dave; matt@codeblueprint.co.uk
> Subject: RE: [PATCH] mm: Introduce kernelcore=reliable option
> 
> > I think /proc/zoneinfo can show detailed numbers per zone. Do we need some for meminfo ?
> 
> I wrote a little script (attached) to summarize /proc/zoneinfo ... on my system it says
> 
> $ zoneinfo
> Node          Normal         Movable             DMA           DMA32
>    0            0.00       103020.07            8.94         1554.46
>    1         9284.54        89870.43
>    2         9626.33        94050.09
>    3         9602.82        93650.04
> 
> Not sure why I have zero Normal memory free on node0.  The sum of all those
> free counts is 410667.72 MB ... which is close enough to the boot time message
> showing the amount of mirror/total memory:
> 
> [    0.000000] efi: Memory: 80979/420096M mirrored memory
> 
> but a fair amount of the 80G of mirrored memory seems to have been miscounted
> as Movable instead of Normal. Perhaps this is because I have two blocks of mirrored
> memory on each node and the movable zone code doesn't expect that?

 You were saying that OS view of memory of node is something like the following ?
  
    Node X:  |MMMMMM------MMMMMM--------|  
       (legend) M: mirrored  -: not mirrrored

 If so, is this a real Box's configuration?
 Sorry, I haven't got a real Address Range Mirror capable boxes yet ...
 I thought mirroring range is concatenated at the first part of each node.

 Sincerely,
 Taku Izumi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
