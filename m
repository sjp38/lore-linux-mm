Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B9B856B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 20:04:36 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 184so257372wmy.18
        for <linux-mm@kvack.org>; Mon, 01 May 2017 17:04:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g207si10253506wme.150.2017.05.01.17.04.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 17:04:35 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v41Ns6M0036110
	for <linux-mm@kvack.org>; Mon, 1 May 2017 20:04:34 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a6afvadws-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 20:04:34 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 1 May 2017 20:04:33 -0400
Date: Mon, 1 May 2017 19:04:25 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
 <20170501210415.aeuvd73auomvdmba@arbab-laptop.localdomain>
 <ce589129-d86c-ba43-7e04-55acf08f7f29@nvidia.com>
 <20170501235123.2k372i75vxlw5n75@arbab-vm>
 <d7e4b032-0c73-92fa-9c70-fbda98df849c@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d7e4b032-0c73-92fa-9c70-fbda98df849c@nvidia.com>
Message-Id: <20170502000424.kauqofpp6gxokcmj@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, vbabka@suse.cz, cl@linux.com

On Mon, May 01, 2017 at 04:58:14PM -0700, John Hubbard wrote:
>On 05/01/2017 04:51 PM, Reza Arbab wrote:
>>On Mon, May 01, 2017 at 02:56:34PM -0700, John Hubbard wrote:
>>>On 05/01/2017 02:04 PM, Reza Arbab wrote:
>>>>On Mon, May 01, 2017 at 01:41:55PM -0700, John Hubbard wrote:
>>>>>1. A way to move pages between NUMA nodes, both virtual 
>>>>>address and physical address-based, from kernel mode.
>>>>
>>>>Jerome's migrate_vma() and migrate_dma() should have this 
>>>>covered, including DMA-accelerated copy.
>>>
>>>Yes, that's good. I wasn't sure from this discussion here if 
>>>either or both of those would be used, but now I see.
>>>
>>>Are those APIs ready for moving pages between NUMA nodes? As there 
>>>is no NUMA node id in the API, are we relying on the pages' 
>>>membership (using each page and updating which node it is on)?
>>
>>Yes. Those APIs work by callback. The alloc_and_copy() function you 
>>provide will be called at the appropriate point in the migration. 
>>Yours would allocate from a specific destination node, and copy 
>>using DMA.
>>
>
>hmmm, that reminds me: the whole story of "which device is this, and 
>which NUMA node does it correlate to?" will have to be wired up. That 
>is *probably* all in the device driver, but since I haven't worked 
>through it, I'd be inclined to list it as an item on the checklist, 
>just in case it requires some little hook in the upstream kernel.

I've worked this out. It can be contained to the driver itself.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
