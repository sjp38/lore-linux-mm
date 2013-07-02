Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0B30A6B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 01:28:31 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 2 Jul 2013 06:28:31 +0100
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 7DE50C9003E
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 01:28:26 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r625SRJm57999442
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 01:28:27 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r625SQLK032131
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 02:28:27 -0300
Date: Tue, 2 Jul 2013 10:58:12 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/6] Basic scheduler support for automatic NUMA balancing
Message-ID: <20130702052812.GA2654@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <20130628135422.GA21895@linux.vnet.ibm.com>
 <20130701053947.GQ8362@linux.vnet.ibm.com>
 <20130701084321.GD1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130701084321.GD1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

* Mel Gorman <mgorman@suse.de> [2013-07-01 09:43:21]:

> 
> Thanks. Each of the the two runs had 5 iterations and there is a
> difference in the reported average. Do you know what the standard
> deviation is of the results?

Yes, the results were from 2 different runs. 
I hadnt calculated the std deviation for those runs.
> 
> I'm less concerned about the numa01 results as it is an adverse
> workload on machins with more than two sockets but the numa02 results
> are certainly of concern. My own testing for numa02 showed little or no
> change. Would you mind testing with "Increase NUMA PTE scanning when a
> new preferred node is selected" reverted please?
> 

Here are the results with the last patch reverted as requested by you.

KernelVersion: 3.9.0-mainline_v39+ your patches - last patch
		Testcase:      Min      Max      Avg  StdDev  %Change
		  numa01:  1704.50  1841.82  1757.55   49.27    2.42%
     numa01_THREAD_ALLOC:   433.25   517.07   464.17   28.15  -32.99%
		  numa02:    55.64    61.75    57.70    2.19  -43.52%
	      numa02_SMT:    44.78    53.45    48.72    2.91  -18.53%



Detailed run output here 

numa01 1704.50 248.67 71999.86 207091 1093
numa01_THREAD_ALLOC 461.62 416.89 23064.79 90283 961
numa02 61.75 93.86 2444.21 10652 6
numa02_SMT 46.79 23.13 977.94 1925 8
numa01 1769.09 262.00 74607.77 226677 1313
numa01_THREAD_ALLOC 433.25 365.12 21994.25 88597 773
numa02 55.64 89.52 2250.01 8848 210
numa02_SMT 49.39 19.81 938.86 1376 33
numa01 1841.82 407.73 78683.69 227428 1834
numa01_THREAD_ALLOC 517.07 465.71 26152.60 111689 978
numa02 55.95 103.26 2223.36 8471 158
numa02_SMT 53.45 19.73 962.08 1349 26
numa01 1760.41 474.74 76094.03 231278 2802
numa01_THREAD_ALLOC 456.80 395.35 23170.23 88049 835
numa02 57.18 87.31 2390.11 10804 3
numa02_SMT 44.78 26.48 944.28 1314 7
numa01 1711.91 421.49 77728.30 224185 2103
numa01_THREAD_ALLOC 452.09 430.88 22271.38 83418 2035
numa02 57.97 126.86 2354.34 8991 135
numa02_SMT 49.19 34.99 914.35 1308 22


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
