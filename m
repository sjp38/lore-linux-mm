Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDF476B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 08:35:42 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so16068768pge.5
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 05:35:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y96si21598722plh.249.2017.01.16.05.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 05:35:41 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0GDXs2S115649
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 08:35:41 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 280u3mt88r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 08:35:40 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 16 Jan 2017 19:05:37 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 14F3A3940062
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:05:36 +0530 (IST)
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0GDZVLM39256158
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:05:32 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0GDZVBO018924
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:05:31 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [LSF/MM ATTEND] CDM, HMM, ZONE_DEVICE, Device Memory Infrastructure,
 Page Allocator, CMA
Date: Mon, 16 Jan 2017 19:05:20 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <8954f383-2a25-f89d-e6db-aa7bc12564bd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, Jerome Glisse <jglisse@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>

Hello,

I have been working on a coherent device memory (CDM) representation in
the kernel. Last year, I had posted these two RFCs in this regard which
attempts to represent non-system RAM coherent device memory as a NUMA
node with some allocation restrictions.

https://lkml.org/lkml/2016/10/24/19  (CDM with modified zonelists)
https://lkml.org/lkml/2016/11/22/339 (CDM with modified cpusets)

During the course of this work, I had experimented with existing device
memory frameworks like ZONE_DEVICE, HMM etc. In my quest for isolation,
also looked into how early system boot allocated CMA region can be used
in this regard. Thought I would like to participate primarily on the
device memory management infrastructure discussions (detailed TOPICs
list can be found below) but would also like to contribute in those
areas where I had faced some limitations or the other during the CDM
work.

I would like to attend to discuss on the listed topics on the mailing
list as mentioned below which I have already replied in their respective
threads as well.

(1) [LSF/MM TOPIC/ATTEND] Memory Types
(2) [LSF/MM TOPIC] Un-addressable device memory and block/fs implications
(3) [LSF/MM TOPIC] Memory hotplug, ZONE_DEVICE, and the future of struct page
(4) [LSF/MM ATTEND] HMM, CDM and other infrastructure for device memory management

Apart from this, would like to discuss on the following generic topics
as I had mentioned earlier.

(1) Support for memory hotplug as CMA regions
(2) Seamless migration between LRU pages and device managed non LRU CMA pages
(3) Explore the possibility of enforcing CDM node isolation through a changed
    buddy page allocator specifically how it currently handles requested
    nodemask_t along with cpuset based nodemask at various phases of fast path
    and slow path

Regards
Anshuman



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
