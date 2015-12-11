Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 23D586B0038
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 00:53:31 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id ph11so31777892igc.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 21:53:31 -0800 (PST)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id q11si328648ioi.188.2015.12.10.21.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 21:53:30 -0800 (PST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id B6050AC0316
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:53:19 +0900 (JST)
From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Date: Fri, 11 Dec 2015 05:53:17 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
 <5668D1FA.4050108@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
 <56691819.3040105@huawei.com>
In-Reply-To: <56691819.3040105@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Kamezawa, Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen,
 Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

Dear Xishi,

> Hi Taku,
> 
> Whether it is possible that we rewrite the fallback function in buddy system
> when zone_movable and mirrored_kernelcore are both enabled?

  What does "when zone_movable and mirrored_kernelcore are both enabled?" mean ?
  
  My patchset just provides a new way to create ZONE_MOVABLE.

  Sincerely,
  Taku Izumi
> 
> It seems something like that we add a new zone but the name is zone_movable,
> not zone_mirror. And the prerequisite is that we won't enable these two
> features(movable memory and mirrored memory) at the same time. Thus we can
> reuse the code of movable zone.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
