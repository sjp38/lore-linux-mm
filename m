Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 386706B0260
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:30:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so263566187pfd.0
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 07:30:50 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c66si16258820pfb.26.2017.01.31.07.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 07:30:44 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0VFToN0035281
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:30:43 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28akc17hux-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:30:43 -0500
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 21:00:40 +0530
Received: from d28relay09.in.ibm.com (d28relay09.in.ibm.com [9.184.220.160])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 8FD0C3940033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 21:00:37 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay09.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0VFUb8Q27263146
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 21:00:37 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0VFUalE020261
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 21:00:37 +0530
Subject: Re: [RFC V2 05/12] cpuset: Add cpuset_inc() inside cpuset_init()
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-6-khandual@linux.vnet.ibm.com>
 <20170130203003.dm2ydoi3e6cbbwcj@suse.de>
 <8f442e1d-6c4d-990b-74e7-6d9a16c4576f@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 31 Jan 2017 21:00:33 +0530
MIME-Version: 1.0
In-Reply-To: <8f442e1d-6c4d-990b-74e7-6d9a16c4576f@suse.cz>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Message-Id: <d7b471ea-4d37-58bd-dacc-d61599d6b71f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 01/31/2017 08:06 PM, Vlastimil Babka wrote:
> On 01/30/2017 09:30 PM, Mel Gorman wrote:
>> On Mon, Jan 30, 2017 at 09:05:46AM +0530, Anshuman Khandual wrote:
>>> Currently cpusets_enabled() wrongfully returns 0 even if we have a root
>>> cpuset configured on the system. This got missed when jump level was
>>> introduced in place of number_of_cpusets with the commit 664eeddeef65
>>> ("mm: page_alloc: use jump labels to avoid checking number_of_cpusets")
>>> . This fixes the problem so that cpusets_enabled() returns positive even
>>> for the root cpuset.
>>>
>>> Fixes: 664eeddeef65 ("mm: page_alloc: use jump labels to avoid")
>>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>>
>> Superficially, this appears to always activate the cpuset_enabled
>> branch() when it doesn't really make sense that the root cpuset be
>> restricted.
> 
> Yes that's why root cpuset doesn't "count", as it's not supposed to be
> restricted (it's also documented in cpusets.txt) Thus the "Fixes:" tag
> is very misleading.

Agreed, I have removed the "Fixes: " tag in the proposed RFC already
posted on this thread where it puts it as a new enablement instead
and an addition to the capability what we already have with cpuset.
It will be great if you can please take a look and provide feedback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
