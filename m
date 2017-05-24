Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E0E596B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:51:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p74so205775110pfd.11
        for <linux-mm@kvack.org>; Wed, 24 May 2017 14:51:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e3si7452770plk.67.2017.05.24.14.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 14:51:06 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OLn212125222
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:51:05 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2anh76jn65-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 17:51:05 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 24 May 2017 15:51:04 -0600
Date: Wed, 24 May 2017 16:50:56 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/2] mm, memory_hotplug: drop artificial restriction
 on online/offline
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170524122411.25212-2-mhocko@kernel.org>
Message-Id: <20170524215056.h4r3sdk23bn4c2sr@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, May 24, 2017 at 02:24:10PM +0200, Michal Hocko wrote:
>74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
>memory") has added can_offline_normal which checks the amount of
>memory in !movable zones as long as CONFIG_MOVABLE_NODE is disable.
>It disallows to offline memory if there is nothing left with a
>justification that "memory-management acts bad when we have nodes which
>is online but don't have any normal memory".
>
>74d42d8fe146 ("memory_hotplug: ensure every online node has NORMAL
>memory") has introduced a restriction that every numa node has to have
>at least some memory in !movable zones before a first movable memory
>can be onlined if !CONFIG_MOVABLE_NODE with the same justification
>
>While it is true that not having _any_ memory for kernel allocations on
>a NUMA node is far from great and such a node would be quite subotimal
>because all kernel allocations will have to fallback to another NUMA
>node but there is no reason to disallow such a configuration in
>principle.
>
>Besides that there is not really a big difference to have one memblock
>for ZONE_NORMAL available or none. With 128MB size memblocks the system
>might trash on the kernel allocations requests anyway. It is really
>hard to draw a line on how much normal memory is really sufficient so
>we have to rely on administrator to configure system sanely therefore
>drop the artificial restriction and remove can_offline_normal and
>can_online_high_movable altogether.

I'm really liking all this cleanup of the memory hotplug code. Thanks!  
Much appreciated.

Acked-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
