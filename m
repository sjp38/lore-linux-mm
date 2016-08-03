Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE70C6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 02:38:18 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id pp5so338530116pac.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 23:38:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v27si7317875pfj.178.2016.08.02.23.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 23:38:18 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u736XtZT032908
	for <linux-mm@kvack.org>; Wed, 3 Aug 2016 02:38:17 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24k0bme0w7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Aug 2016 02:38:17 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 3 Aug 2016 16:38:14 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 54A1C2CE802D
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 16:38:12 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u736cCts32636930
	for <linux-mm@kvack.org>; Wed, 3 Aug 2016 16:38:12 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u736cBam027504
	for <linux-mm@kvack.org>; Wed, 3 Aug 2016 16:38:12 +1000
Date: Wed, 3 Aug 2016 12:08:08 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: Allow disabling deferred struct page
 initialisation
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-2-git-send-email-srikar@linux.vnet.ibm.com>
 <57A0E1D1.8020608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <57A0E1D1.8020608@intel.com>
Message-Id: <20160803063808.GI6310@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, mahesh@linux.vnet.ibm.com, hbathini@linux.vnet.ibm.com

* Dave Hansen <dave.hansen@intel.com> [2016-08-02 11:09:21]:

> On 08/02/2016 06:19 AM, Srikar Dronamraju wrote:
> > Kernels compiled with CONFIG_DEFERRED_STRUCT_PAGE_INIT will initialise
> > only certain size memory per node. The certain size takes into account
> > the dentry and inode cache sizes. However such a kernel when booting a
> > secondary kernel will not be able to allocate the required amount of
> > memory to suffice for the dentry and inode caches. This results in
> > crashes like the below on large systems such as 32 TB systems.
> 
> What's a "secondary kernel"?
> 

I mean the kernel thats booted to collect the crash, On fadump, the
first kernel acts as the secondary kernel i.e the same kernel is booted
to collect the crash.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
