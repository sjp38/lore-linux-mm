Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C9AC26B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 12:16:01 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 10 Dec 2012 12:16:00 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 126CA38C8062
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 12:12:48 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBAHClBI238766
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 12:12:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBAHCkIX001227
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 15:12:47 -0200
Date: Mon, 10 Dec 2012 22:12:25 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121210164225.GC6348@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel, Ingo, 

Here are the results of running autonumabenchmark on a 64 core, 8 node
machine. Has six 32GB nodes and two 64 GB nodes.


KernelVersion: 3.7.0-rc8
                        Testcase:      Min      Max      Avg
                          numa01:  1475.37  1615.39  1555.24
                numa01_HARD_BIND:   900.42  1244.00   993.30
             numa01_INVERSE_BIND:  2835.44  5067.22  3634.86
             numa01_THREAD_ALLOC:   918.51  1384.21  1121.17
   numa01_THREAD_ALLOC_HARD_BIND:   599.58  1178.26   792.73
numa01_THREAD_ALLOC_INVERSE_BIND:  1841.33  2237.34  1988.95
                          numa02:   126.95   188.31   147.04
                numa02_HARD_BIND:    26.05    29.17    26.94
             numa02_INVERSE_BIND:   341.10   369.37   349.10
                      numa02_SMT:   144.32   922.65   386.43
            numa02_SMT_HARD_BIND:    26.61   170.71   101.98
         numa02_SMT_INVERSE_BIND:   288.12   456.45   325.26

KernelVersion: 3.7.0-rc8-tip_master+(December 7th Snapshot)
                        Testcase:      Min      Max      Avg  %Change
                          numa01:  2927.89  3217.56  3103.21  -49.88%
                numa01_HARD_BIND:  2653.09  5964.23  3431.35  -71.05%
             numa01_INVERSE_BIND:  3567.03  3933.18  3811.91   -4.64%
             numa01_THREAD_ALLOC:  1801.80  2339.16  1980.96  -43.40%
   numa01_THREAD_ALLOC_HARD_BIND:  1705.84  2110.06  1913.64  -58.57%
numa01_THREAD_ALLOC_INVERSE_BIND:  2266.12  2540.61  2376.67  -16.31%
                          numa02:   179.26   358.03   264.19  -44.34%
                numa02_HARD_BIND:    26.07    29.38    27.70   -2.74%
             numa02_INVERSE_BIND:   337.99   347.95   343.51    1.63%
                      numa02_SMT:    93.65   402.58   213.15   81.29%
            numa02_SMT_HARD_BIND:    91.19   140.47   116.26  -12.28%
         numa02_SMT_INVERSE_BIND:   289.03   299.57   297.01    9.51%

KernelVersion: 3.7.0-rc6-mel_auto_balance(mm-balancenuma-v10r3)
                        Testcase:      Min      Max      Avg  %Change
                          numa01:  1536.93  1819.85  1694.54   -8.22%
                numa01_HARD_BIND:   909.67  1145.32  1055.57   -5.90%
             numa01_INVERSE_BIND:  2882.07  3287.24  2976.89   22.10%
             numa01_THREAD_ALLOC:   995.79  4845.27  1905.85  -41.17%
   numa01_THREAD_ALLOC_HARD_BIND:   582.36   818.11   655.18   20.99%
numa01_THREAD_ALLOC_INVERSE_BIND:  1790.91  1927.90  1868.49    6.45%
                          numa02:   131.53   287.93   209.15  -29.70%
                numa02_HARD_BIND:    25.68    31.90    27.66   -2.60%
             numa02_INVERSE_BIND:   341.09   401.37   353.84   -1.34%
                      numa02_SMT:   156.61  2036.63   731.97  -47.21%
            numa02_SMT_HARD_BIND:    25.10   196.60    79.72   27.92%
         numa02_SMT_INVERSE_BIND:   294.22  1801.59   824.41  -60.55%

KernelVersion: 3.7.0-rc6-autonuma+(mm-autonuma-v28fastr4-mels-rebase)
                        Testcase:      Min      Max      Avg  %Change
                          numa01:  1596.13  1715.34  1649.44   -5.71%
                numa01_HARD_BIND:   920.75  1127.86  1012.50   -1.90%
             numa01_INVERSE_BIND:  2858.79  3146.74  2977.16   22.09%
             numa01_THREAD_ALLOC:   250.55   374.27   290.12  286.45%
   numa01_THREAD_ALLOC_HARD_BIND:   572.29   712.74   630.62   25.71%
numa01_THREAD_ALLOC_INVERSE_BIND:  1835.94  2401.04  2011.20   -1.11%
                          numa02:    33.93   104.80    50.99  188.37%
                numa02_HARD_BIND:    25.94    27.51    26.42    1.97%
             numa02_INVERSE_BIND:   334.57   349.51   341.23    2.31%
                      numa02_SMT:    43.72   114.82    62.41  519.18%
            numa02_SMT_HARD_BIND:    34.98    45.61    42.07  142.41%
         numa02_SMT_INVERSE_BIND:   284.57   310.62   298.51    8.96%

Avg refers to mean of 5 iterations of autonuma-benchmark.
%Change refers to percentage change from 3.7-rc8

Please do let me know if you have questions/suggestions.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
