Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D5FC56B02FD
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 11:20:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q27so45207900pfi.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 08:20:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l25si4140172pli.38.2017.06.01.08.20.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 08:20:20 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v51FK367018147
	for <linux-mm@kvack.org>; Thu, 1 Jun 2017 11:20:19 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2atnc5g8yc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:20:19 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 1 Jun 2017 11:19:44 -0400
Date: Thu, 1 Jun 2017 10:19:36 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] mm, memory_hotplug: support movable_node for
 hotplugable nodes
References: <20170601122004.32732-1-mhocko@kernel.org>
 <820164f3-8bef-7761-0695-88db9e0ce7a7@suse.cz>
 <20170601142227.GF9091@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170601142227.GF9091@dhcp22.suse.cz>
Message-Id: <20170601151935.m5jbfmugocc66qfq@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 01, 2017 at 04:22:28PM +0200, Michal Hocko wrote:
>On Thu 01-06-17 16:11:55, Vlastimil Babka wrote:
>> Simple should work, hopefully.
>> - if memory is hotplugged, it's obviously hotplugable, so we don't have
>> to rely on BIOS description.
>
>Not sure I understand. We do not have any information about the hotplug
>status at the time we do online.

The x86 SRAT (or the dt, on other platforms) can describe memory as 
hotpluggable. See memblock_mark_hotplug(). That's only for memory 
present at boot, though.

He's saying that since the memory was added after boot, it is by 
definition hotpluggable. There's no need to check for that 
marking/description.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
