Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5878E830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:12:58 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o1so314909674qkd.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:12:58 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j198si6237115qke.170.2016.08.29.06.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 06:12:57 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7TDC4nY007467
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:12:57 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 253reg5u17-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:12:56 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 23:12:53 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 192612BB0057
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:12:51 +1000 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7TDCpIu524550
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:12:51 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7TDCoGX018017
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:12:50 +1000
Date: Mon, 29 Aug 2016 18:42:46 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 2/2] fadump: Register the memory reserved by fadump
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470330729-6273-2-git-send-email-srikar@linux.vnet.ibm.com>
 <20160804140133.edf295b8263845e50c185fc2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160804140133.edf295b8263845e50c185fc2@linux-foundation.org>
Message-Id: <20160829131246.GA2505@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

* Andrew Morton <akpm@linux-foundation.org> [2016-08-04 14:01:33]:

> > Register the memory reserved by fadump, so that the cache sizes are
> > calculated based on the free memory (i.e Total memory - reserved
> > memory).
> 
> Looks harmless enough to me.  I'll schedule the patches for 4.8.  But
> it sounds like they should be backported into older kernels?
> 

Based on the v2 feedback, I just posted a v3 at
http://lkml.kernel.org/r/1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com
that tries to reduce the large system hash based on tha reserved memory.
Hence please drop the v2 patches.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
