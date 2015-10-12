Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EFFA96B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 14:43:32 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so102806024pab.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:43:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id de10si28064274pad.66.2015.10.12.11.43.31
        for <linux-mm@kvack.org>;
        Mon, 12 Oct 2015 11:43:31 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH][RFC] mm: Introduce kernelcore=reliable option
Date: Mon, 12 Oct 2015 18:43:30 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B54CDF@ORSMSX114.amr.corp.intel.com>
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com> <561787DA.4040809@jp.fujitsu.com>
 <5617989E.9070700@huawei.com> <56187188.4070103@huawei.com>
In-Reply-To: <56187188.4070103@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, "zhongjiang@huawei.com" <zhongjiang@huawei.com>, Naoya
 Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Leon Romanovsky <leon@leon.nu>

> If we reuse the movable zone, we should set appropriate size of
> mirrored memory region(normal zone) and non-mirrored memory
> region(movable zone). In some cases, kernel will take more memory
> than user, e.g. some apps run in kernel space, like module.
>
> I think user can set the size in BIOS interface, right?

Exact methods may vary as different BIOS vendors implement things the way
they like (or the way an OEM asks them).  In the Intel reference BIOS you c=
an either
set an explicit mirror size for each memory controller, or you can have the=
 BIOS
look at some EFI boot variables to find a percentage of memory to use sprea=
d
across all memory controllers.

See:
https://software.intel.com/sites/default/files/managed/43/6a/Memory%20Addre=
ss%20Range%20Mirroring%20Validation%20Guide.pdf

There are patches to efibootmgr(8) to set/show the EFI variables:
git://github.com/rhinstaller/efibootmgr

-Tony
=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
