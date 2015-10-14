Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 927DD6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 21:19:54 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so37131620pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 18:19:54 -0700 (PDT)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id t16si8974825pbs.225.2015.10.13.18.19.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 18:19:53 -0700 (PDT)
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 77053AC007E
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:19:50 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH][RFC] mm: Introduce kernelcore=reliable option
Date: Wed, 14 Oct 2015 01:19:47 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5427EA26@G01JPEXMBYT01>
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F32B534D5@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32B534D5@ORSMSX114.amr.corp.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "Hansen, Dave" <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>

> > I remember Kame has already suggested this idea. In my opinion,
> > I still think it's better to add a new migratetype or a new zone,
> > so both user and kernel could use mirrored memory.
> 
> A new zone would be more flexible ... and probably the right long
> term solution.  But this looks like a very clever was to try out the
> feature with a minimally invasive patch.

 Yes. I agree creating a new zone is the right solution for long term.
 I believe this approach using MOVABLE_ZONE is good and reasonable 
 for short-term solution.

Sincerely,
Taku Izumi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
