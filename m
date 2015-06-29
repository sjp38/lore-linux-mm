Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0E59C6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:19:14 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so106933854pab.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:19:13 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id qu16si64909286pab.222.2015.06.29.08.19.11
        for <linux-mm@kvack.org>;
        Mon, 29 Jun 2015 08:19:13 -0700 (PDT)
Message-ID: <559161EF.7050405@intel.com>
Date: Mon, 29 Jun 2015 08:19:11 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/26/2015 07:19 PM, Xishi Qiu wrote:
>  drivers/base/node.c      |  17 ++++---
>  fs/proc/meminfo.c        |   6 +++
>  include/linux/memblock.h |  29 ++++++++++--
>  include/linux/mmzone.h   |  10 ++++
>  include/linux/vmstat.h   |   2 +
>  mm/Kconfig               |   8 ++++
>  mm/memblock.c            |  33 +++++++++++--
>  mm/nobootmem.c           |   3 ++
>  mm/page_alloc.c          | 117 ++++++++++++++++++++++++++++++++++++-----------
>  mm/vmstat.c              |   4 ++
>  10 files changed, 190 insertions(+), 39 deletions(-)

Has there been any performance analysis done on this code?  I'm always
nervous when I see page_alloc.c churn.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
