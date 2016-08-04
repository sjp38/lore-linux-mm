Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1816B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 11:28:00 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so136405641lfw.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 08:28:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a64si4501812wmc.86.2016.08.04.08.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 08:27:58 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u74FO3Cb142011
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 11:27:57 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kxmhkvr0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:27:57 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 20:57:53 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 7ADED1258066
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 21:00:54 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u74FRnO354525954
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 20:57:49 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u74FRke8008845
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 20:57:48 +0530
Date: Thu, 4 Aug 2016 20:57:43 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20160804140934.GM2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160804140934.GM2799@techsingularity.net>
Message-Id: <20160804152743.GD11268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

* Mel Gorman <mgorman@techsingularity.net> [2016-08-04 15:09:34]:

> > 
> > Suggested-by: Mel Gorman <mgorman@techsingularity.net>
> 
> I didn't suggest this specifically. While it happens to be safe on ppc64,
> it potentially overwrites any future caller of set_dma_reserve. While the
> only other one is for the e820 map, it may be better to change the API
> to inc_dma_reserve?
> 
> It's also unfortunate that it's called dma_reserve because it has
> nothing to do with DMA or ZONE_DMA. inc_kernel_reserve may be more
> appropriate?

Yup Agree. Will redo and send out.

> 
> -- 
> Mel Gorman
> SUSE Labs
> 

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
