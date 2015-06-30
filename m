Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id B44076B006E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 21:34:35 -0400 (EDT)
Received: by qgii30 with SMTP id i30so12858125qgi.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 18:34:35 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id i206si43400702qhc.13.2015.06.29.18.34.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 18:34:35 -0700 (PDT)
Message-ID: <5591F042.1020304@huawei.com>
Date: Tue, 30 Jun 2015 09:26:26 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
References: <558E084A.60900@huawei.com> <559161EF.7050405@intel.com>
In-Reply-To: <559161EF.7050405@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/29 23:19, Dave Hansen wrote:

> On 06/26/2015 07:19 PM, Xishi Qiu wrote:
>>  drivers/base/node.c      |  17 ++++---
>>  fs/proc/meminfo.c        |   6 +++
>>  include/linux/memblock.h |  29 ++++++++++--
>>  include/linux/mmzone.h   |  10 ++++
>>  include/linux/vmstat.h   |   2 +
>>  mm/Kconfig               |   8 ++++
>>  mm/memblock.c            |  33 +++++++++++--
>>  mm/nobootmem.c           |   3 ++
>>  mm/page_alloc.c          | 117 ++++++++++++++++++++++++++++++++++++-----------
>>  mm/vmstat.c              |   4 ++
>>  10 files changed, 190 insertions(+), 39 deletions(-)
> 
> Has there been any performance analysis done on this code?  I'm always
> nervous when I see page_alloc.c churn.
> 

Not yet, which benchmark do you suggest?

Thanks,
Xishi Qiu

> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
