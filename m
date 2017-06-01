Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A92E6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:02:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k15so11233528wmh.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:02:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p92si22014512edb.320.2017.06.01.09.02.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 09:02:38 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v51FwuhT091278
	for <linux-mm@kvack.org>; Thu, 1 Jun 2017 12:02:36 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ata1nm6bg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Jun 2017 12:02:36 -0400
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 1 Jun 2017 12:02:35 -0400
Date: Thu, 1 Jun 2017 11:02:28 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] mm, memory_hotplug: support movable_node for
 hotplugable nodes
References: <20170601122004.32732-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170601122004.32732-1-mhocko@kernel.org>
Message-Id: <20170601160227.uioluvgvjtplesjr@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, Jun 01, 2017 at 02:20:04PM +0200, Michal Hocko wrote:
>Teach move_pfn_range that MMOP_ONLINE_KEEP can use the movable zone if
>movable_node is enabled and the range doesn't overlap with the existing
>normal zone. This should provide a reasonable default onlining strategy.

I like it. If your distro has some auto-onlining udev rule like

SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"

You could get things onlined as movable just by putting movable_node in
the boot params, without changing/modifying the rule.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
