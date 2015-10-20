Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B7D586B0253
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 20:35:00 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so2279833pad.1
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 17:35:00 -0700 (PDT)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id w15si582024pbt.47.2015.10.19.17.34.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 17:35:00 -0700 (PDT)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 887D5AC0172
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 09:34:53 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH] mm: Introduce kernelcore=reliable option
Date: Tue, 20 Oct 2015 00:34:51 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5427FECE@G01JPEXMBYT01>
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <5624548F.30500@huawei.com>
In-Reply-To: <5624548F.30500@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

 Hi Xishi,

> On 2015/10/15 21:32, Taku Izumi wrote:
> 
> > Xeon E7 v3 based systems supports Address Range Mirroring
> > and UEFI BIOS complied with UEFI spec 2.5 can notify which
> > ranges are reliable (mirrored) via EFI memory map.
> > Now Linux kernel utilize its information and allocates
> > boot time memory from reliable region.
> >
> > My requirement is:
> >   - allocate kernel memory from reliable region
> >   - allocate user memory from non-reliable region
> >
> > In order to meet my requirement, ZONE_MOVABLE is useful.
> > By arranging non-reliable range into ZONE_MOVABLE,
> > reliable memory is only used for kernel allocations.
> >
> > This patch extends existing "kernelcore" option and
> > introduces kernelcore=reliable option. By specifying
> > "reliable" instead of specifying the amount of memory,
> > non-reliable region will be arranged into ZONE_MOVABLE.
> >
> > Earlier discussion is at:
> >  https://lkml.org/lkml/2015/10/9/24
> >
> 
> Hi Taku,
> 
> If user don't want to waste a lot of memory, and he only set
> a few memory to mirrored memory, then the kernelcore is very
> small, right? That means OS will have a very small normal zone
> and a very large movable zone.

 Right.

> Kernel allocation could only use the unmovable zone. As the
> normal zone is very small, the kernel allocation maybe OOM,
> right?

 Right.

> Do you mean that we will reuse the movable zone in short-term
> solution and create a new zone(mirrored zone) in future?

 If there is that kind of requirements, I don't oppose 
 creating a new zone.

 Sincerely,
 Taku Izumi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
