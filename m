Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9BF6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 20:39:04 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id ph11so884070igc.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 17:39:04 -0800 (PST)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id c187si3836542ioe.136.2015.12.16.17.39.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 17:39:03 -0800 (PST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 2965EAC0234
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 10:38:58 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Date: Thu, 17 Dec 2015 01:38:55 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
 <5668D1FA.4050108@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
 <56691819.3040105@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
 <566A9AE1.7020001@huawei.com>
In-Reply-To: <566A9AE1.7020001@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen,
 Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

Dear Xishi,

 Sorry for late.

> -----Original Message-----
> From: Xishi Qiu [mailto:qiuxishi@huawei.com]
> Sent: Friday, December 11, 2015 6:44 PM
> To: Izumi, Taku/泉 拓
> Cc: Luck, Tony; linux-kernel@vger.kernel.org; linux-mm@kvack.org; akpm@linux-foundation.org; Kamezawa, Hiroyuki/亀澤 寛
> 之; mel@csn.ul.ie; Hansen, Dave; matt@codeblueprint.co.uk
> Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
> 
> On 2015/12/11 13:53, Izumi, Taku wrote:
> 
> > Dear Xishi,
> >
> >> Hi Taku,
> >>
> >> Whether it is possible that we rewrite the fallback function in buddy system
> >> when zone_movable and mirrored_kernelcore are both enabled?
> >
> >   What does "when zone_movable and mirrored_kernelcore are both enabled?" mean ?
> >
> >   My patchset just provides a new way to create ZONE_MOVABLE.
> >
> 
> Hi Taku,
> 
> I mean when zone_movable is from kernelcore=mirror, not kernelcore=nn[KMG].

  I'm not quite sure what you are saying, but if you want to screen user memory
  so that one is allocated from mirrored zone and another is from non-mirrored zone,
  I think it is possible to reuse my patchset.

  Sincerely,
  Taku Izumi

> Thanks,
> Xishi Qiu
> 
> >   Sincerely,
> >   Taku Izumi
> >>
> >> It seems something like that we add a new zone but the name is zone_movable,
> >> not zone_mirror. And the prerequisite is that we won't enable these two
> >> features(movable memory and mirrored memory) at the same time. Thus we can
> >> reuse the code of movable zone.
> >>
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >
> > .
> >
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
