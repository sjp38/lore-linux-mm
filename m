Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE136B0038
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 11:47:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 68so39951782pgj.23
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 08:47:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e9si2209822plk.150.2017.04.06.08.47.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 08:47:04 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v36FdBE1116572
	for <linux-mm@kvack.org>; Thu, 6 Apr 2017 11:47:04 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29nq7wvd10-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Apr 2017 11:47:03 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 6 Apr 2017 11:47:02 -0400
Date: Thu, 6 Apr 2017 10:46:53 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170406130846.GL5497@dhcp22.suse.cz>
 <20170406152449.zmghwdb4y6hxn4pm@arbab-laptop>
 <20170406154127.GQ5497@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170406154127.GQ5497@dhcp22.suse.cz>
Message-Id: <20170406154653.yv4i2k2r7hjq6mke@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Apr 06, 2017 at 05:41:28PM +0200, Michal Hocko wrote:
>On Thu 06-04-17 10:24:49, Reza Arbab wrote:
>> On Thu, Apr 06, 2017 at 03:08:46PM +0200, Michal Hocko wrote:
>> >OK, so after recent change mostly driven by testing from Reza Arbab
>> >(thanks again) I believe I am getting to a working state finally. All I
>> >currently have is
>> >in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git tree
>> >attempts/rewrite-mem_hotplug-WIP branch. I will highly appreciate more
>> >testing of course and if there are no new issues found I will repost the
>> >series for the review.
>>
>> Looking good! I can do my add/remove/repeat test and things seem fine.
>>
>> One thing--starting on the second iteration, I am seeing the WARN in
>> free_area_init_node();
>>
>> add_memory
>>  add_memory_resource
>>    hotadd_new_pgdat
>>      free_area_init_node
>> 	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
>
>Have you tested with my attempts/rewrite-mem_hotplug-WIP mentioned
>elsewhere? Because I suspect that "mm: get rid of zone_is_initialized"
>might cause this.

This was my first time using your git branch instead of applying the 
patches from this thread to v4.11-rc5 myself.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
