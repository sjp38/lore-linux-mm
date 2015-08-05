Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 45D886B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 10:50:43 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so6036245pab.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 07:50:43 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id bg17si5660857pad.159.2015.08.05.07.50.40
        for <linux-mm@kvack.org>;
        Wed, 05 Aug 2015 07:50:41 -0700 (PDT)
Message-ID: <55C221EB.7060500@intel.com>
Date: Wed, 05 Aug 2015 07:47:07 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add the block to the tail of the list in expand()
References: <55BB4027.7080200@huawei.com> <55BC0392.2070205@intel.com> <55BECC85.7050206@huawei.com> <55BEE99E.8090901@intel.com> <55C011A6.1090003@huawei.com> <55C0CBC3.2000602@intel.com> <55C1C132.2010805@huawei.com>
In-Reply-To: <55C1C132.2010805@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, iamjoonsoo.kim@lge.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/05/2015 12:54 AM, Xishi Qiu wrote:
> I add some debug code like this, but it doesn't trigger the dump_stack().
...
> +         if (!list_empty(&area->free_list[migratetype])) {
> +                 printk("expand(), the list is not empty\n");
> +                 dump_stack();
> +         }
> +

That will probably not trigger unless you have allocations that are
falling back and converting other pageblocks from other migratetypes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
