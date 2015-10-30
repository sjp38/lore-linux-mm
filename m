Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C9C8182F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 02:20:20 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so67045394pac.3
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 23:20:20 -0700 (PDT)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id fe1si4370160pab.82.2015.10.29.23.20.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 23:20:19 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id D3092AC0317
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 15:20:10 +0900 (JST)
Subject: Re: [PATCH] mm: Introduce kernelcore=reliable option
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
 <5628B427.3050403@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5C7AE@ORSMSX114.amr.corp.intel.com>
 <E86EADE93E2D054CBCD4E708C38D364A54280C26@G01JPEXMBYT01>
 <322B7BFA-08FE-4A8F-B54C-86901BDB7CBD@intel.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56330C0A.3060901@jp.fujitsu.com>
Date: Fri, 30 Oct 2015 15:19:54 +0900
MIME-Version: 1.0
In-Reply-To: <322B7BFA-08FE-4A8F-B54C-86901BDB7CBD@intel.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/10/23 10:44, Luck, Tony wrote:
> First part of each memory controller. I have two memory controllers on each node
> 

If each memory controller has the same distance/latency, you (your firmware) don't need
to allocate reliable memory per each memory controller.
If distance is problem, another node should be allocated.

...is the behavior(splitting zone) really required ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
