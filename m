Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 801936B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:54:38 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so96265642pab.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:54:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b81si19154472pfb.21.2016.08.05.00.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 00:28:54 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u757PZtv057147
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 03:28:52 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kkaj9rs1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 05 Aug 2016 03:28:52 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 5 Aug 2016 17:28:48 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9A27E2CE805A
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 17:28:45 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u757SjYe24641760
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 17:28:45 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u757ShSa026235
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 17:28:45 +1000
Date: Fri, 5 Aug 2016 12:58:38 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
 <87mvkritii.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <87mvkritii.fsf@concordia.ellerman.id.au>
Message-Id: <20160805072838.GF11268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

* Michael Ellerman <mpe@ellerman.id.au> [2016-08-05 17:07:01]:

> Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:
> 
> > Fadump kernel reserves large chunks of memory even before the pages are
> > initialized. This could mean memory that corresponds to several nodes might
> > fall in memblock reserved regions.
> >
> ...
> > Register the memory reserved by fadump, so that the cache sizes are
> > calculated based on the free memory (i.e Total memory - reserved
> > memory).
> 
> The memory is reserved, with memblock_reserve(). Why is that not sufficient?
> 
> cheers
> 

Because at page initialization time, the kernel doesnt know how many
pages are reserved. One way to do that would be to walk through the
different memory reserved blocks and calculate the size. But Mel feels
thats an overhead (from his reply to the other thread) esp for just one
use case.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
