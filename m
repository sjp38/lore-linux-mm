Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F25B6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 17:04:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y22so10805698wry.1
        for <linux-mm@kvack.org>; Mon, 01 May 2017 14:04:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c69si107405wmi.125.2017.05.01.14.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 14:04:24 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v41KrSjT052736
	for <linux-mm@kvack.org>; Mon, 1 May 2017 17:04:23 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a6awvbwgc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 01 May 2017 17:04:23 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 1 May 2017 15:04:22 -0600
Date: Mon, 1 May 2017 16:04:15 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
Message-Id: <20170501210415.aeuvd73auomvdmba@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, vbabka@suse.cz, cl@linux.com

On Mon, May 01, 2017 at 01:41:55PM -0700, John Hubbard wrote:
>1. A way to move pages between NUMA nodes, both virtual address and 
>physical address-based, from kernel mode.

Jerome's migrate_vma() and migrate_dma() should have this covered, 
including DMA-accelerated copy.

>5. Something to handle the story of bringing NUMA nodes online and 
>putting them back offline, given that they require a device driver that 
>may not yet have been loaded. There are a few minor missing bits there.

This has been prototyped with the driver doing memory hotplug/hotremove.  
Could you elaborate a little on what you feel is missing?

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
