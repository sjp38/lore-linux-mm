Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BE606B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 05:07:02 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id f62so3574179otf.6
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 02:07:02 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id i50si2291522otb.412.2017.12.01.02.06.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 02:07:01 -0800 (PST)
Subject: Re: stalled MM patches
References: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <372f0b21-b987-229b-840f-d37866263bde@huawei.com>
Date: Fri, 1 Dec 2017 17:58:28 +0800
MIME-Version: 1.0
In-Reply-To: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexandru Moise <00moses.alexander00@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrey
 Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique
 de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel
 Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore
 Ts'o <tytso@mit.edu>, Vinayak Menon <vinmenon@codeaurora.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, zhong jiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org

Hi, Andrew

On 2017/12/1 6:14, Andrew Morton wrote:
> 
> I'm sitting on a bunch of patches of varying ages which are stuck for
> various reason.  Can people please take a look some time and assist
> with getting them merged, dropped or fixed?
> 
> I'll send them all out in a sec.  I have rough notes (which might be
> obsolete) and additional details can be found by following the Link: in
> the individual patches.
> 
> Thanks.
> 
> Subject: mm: skip HWPoisoned pages when onlining pages
> 
>   mhocko had issues with this one.
> 
> Subject: mm/mempolicy: remove redundant check in get_nodes
> Subject: mm/mempolicy: fix the check of nodemask from user
> Subject: mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
> 
>   Three patch series.  Stuck because vbabka wasn't happy with #3.
> 
I will send anther version for the patch #3.

Thanks
Yisheng Xie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
