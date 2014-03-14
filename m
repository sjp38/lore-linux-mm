Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id B1CCA6B0071
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 07:58:55 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so2507302pbb.19
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 04:58:55 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id xr10si3672166pab.193.2014.03.14.04.58.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 04:58:54 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 14 Mar 2014 21:58:50 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 661432CE8055
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 22:58:47 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2EBcXwr66584702
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 22:38:34 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2EBwjpL003610
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 22:58:46 +1100
Date: Fri, 14 Mar 2014 17:28:43 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] numa: Use LAST_CPUPID_SHIFT to calculate LAST_CPUPID_MASK
Message-ID: <20140314115843.GD23154@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20140314115556.GA10406@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20140314115556.GA10406@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Ping Fan <qemulist@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Some performance numbers and perf stats with and without the fix.

(3.14-rc6)
----------
numa01

 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa01':

         12,27,462 cs                                                           [100.00%]
          2,41,957 migrations                                                   [100.00%]
       1,68,01,713 faults                                                       [100.00%]
    7,99,35,29,041 cache-misses
            98,808 migrate:mm_migrate_pages                                     [100.00%]

    1407.690148814 seconds time elapsed

numa02

 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa02':

            63,065 cs                                                           [100.00%]
            14,364 migrations                                                   [100.00%]
          2,08,118 faults                                                       [100.00%]
      25,32,59,404 cache-misses
                12 migrate:mm_migrate_pages                                     [100.00%]

      63.840827219 seconds time elapsed


(3.14-rc6 with fix)
-------------------
numa01

 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa01':

          9,68,911 cs                                                           [100.00%]
          1,01,414 migrations                                                   [100.00%]
         88,38,697 faults                                                       [100.00%]
    4,42,92,51,042 cache-misses
          4,25,060 migrate:mm_migrate_pages                                     [100.00%]

     685.965331189 seconds time elapsed

numa02

 Performance counter stats for '/usr/bin/time -f %e %S %U %c %w -o start_bench.out -a ./numa02':

            17,543 cs                                                           [100.00%]
             2,962 migrations                                                   [100.00%]
          1,17,843 faults                                                       [100.00%]
      11,80,61,644 cache-misses
            12,358 migrate:mm_migrate_pages                                     [100.00%]

      20.380132343 seconds time elapsed

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
