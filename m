Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 178C86B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:59:20 -0500 (EST)
Received: by pfnn128 with SMTP id n128so36382753pfn.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:59:19 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id qy7si15208869pab.169.2015.12.09.13.59.19
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 13:59:19 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Date: Wed, 9 Dec 2015 21:59:17 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
In-Reply-To: <56679FDC.1080800@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen,
 Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

> How about add some comment, if mirrored memroy is too small, then the
> normal zone is small, so it may be oom.
> The mirrored memory is at least 1/64 of whole memory, because struct
> pages usually take 64 bytes per page.

1/64th is the absolute lower bound (for the page structures as you say). I
expect people will need to configure 10% or more to run any real workloads.

I made the memblock boot time allocator fall back to non-mirrored memory
if mirrored memory ran out.  What happens in the run time allocator if the
non-movable zones run out of pages? Will we allocate kernel pages from mova=
ble
memory?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
