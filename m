Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7750C6B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 11:41:47 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m28so49326452pgn.14
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 08:41:47 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30080.outbound.protection.outlook.com. [40.107.3.80])
        by mx.google.com with ESMTPS id o4si2481252plb.192.2017.03.30.08.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 08:41:46 -0700 (PDT)
Subject: Re: [PATCH 2/6] mm, tile: drop arch_{add,remove}_memory
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170330115454.32154-3-mhocko@kernel.org>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <b174a772-fa4c-f661-44ac-4c48efa05189@mellanox.com>
Date: Thu, 30 Mar 2017 11:41:33 -0400
MIME-Version: 1.0
In-Reply-To: <20170330115454.32154-3-mhocko@kernel.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 3/30/2017 7:54 AM, Michal Hocko wrote:
> From: Michal Hocko<mhocko@suse.com>
>
> these functions are unreachable because tile doesn't support memory
> hotplug becasuse it doesn't select ARCH_ENABLE_MEMORY_HOTPLUG nor
> it supports SPARSEMEM.
>
> This code hasn't been compiled for a while obviously because nobody has
> noticed that __add_pages has a different signature since 2009.
>
> Cc: Chris Metcalf<cmetcalf@mellanox.com>
> Signed-off-by: Michal Hocko<mhocko@suse.com>
> ---
>   arch/tile/mm/init.c | 30 ------------------------------
>   1 file changed, 30 deletions(-)

Thanks - taken into the tile tree.

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
