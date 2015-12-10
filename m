Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id A237782F7A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 00:37:53 -0500 (EST)
Received: by iofh3 with SMTP id h3so84435217iof.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 21:37:53 -0800 (PST)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id xg10si17736119igb.51.2015.12.09.21.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 21:37:52 -0800 (PST)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id BACEFAC0333
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 14:37:43 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Date: Thu, 10 Dec 2015 05:37:41 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
 <5668D1FA.4050108@huawei.com>
In-Reply-To: <5668D1FA.4050108@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen,
 Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

Dear Tony, Xishi,

> >> How about add some comment, if mirrored memroy is too small, then the
> >> normal zone is small, so it may be oom.
> >> The mirrored memory is at least 1/64 of whole memory, because struct
> >> pages usually take 64 bytes per page.
> >
> > 1/64th is the absolute lower bound (for the page structures as you say). I
> > expect people will need to configure 10% or more to run any real workloads.

> >
> > I made the memblock boot time allocator fall back to non-mirrored memory
> > if mirrored memory ran out.  What happens in the run time allocator if the
> > non-movable zones run out of pages? Will we allocate kernel pages from movable
> > memory?
> >
> 
> As I know, the kernel pages will not allocated from movable zone.

 Yes, kernel pages are not allocated from ZONE_MOVABLE.

 In this case administrator must review and reconfigure the mirror ratio via 
 "MirrorRequest" EFI variable.
 
  Sincerely,
  Taku Izumi

>
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
