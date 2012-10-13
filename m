Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 16C126B002B
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 14:41:09 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Sat, 13 Oct 2012 12:41:08 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id AE9B13E4003E
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 12:41:01 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9DIf4OI224216
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 12:41:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9DIf2xH023402
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 12:41:04 -0600
Date: Sun, 14 Oct 2012 00:10:19 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/33] AutoNUMA27
Message-ID: <20121013184019.GA3837@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, pzijlstr@redhat.com, mingo@elte.hu, mel@csn.ul.ie, hughd@google.com, riel@redhat.com, hannes@cmpxchg.org, dhillf@gmail.com, drjones@redhat.com, tglx@linutronix.de, pjt@google.com, cl@linux.com, suresh.b.siddha@intel.com, efault@gmx.de, paulmck@linux.vnet.ibm.com, alex.shi@intel.com, konrad.wilk@oracle.com, benh@kernel.crashing.org

* Andrea Arcangeli <aarcange@redhat.com> [2012-10-04 01:50:42]:

> Hello everyone,
> 
> This is a new AutoNUMA27 release for Linux v3.6.
> 


Here results of autonumabenchmark on a 328GB 64 core with ht disabled
comparing v3.6 with autonuma27.

$ numactl -H 
available: 8 nodes (0-7)
node 0 cpus: 0 1 2 3 4 5 6 7
node 0 size: 32510 MB
node 0 free: 31689 MB
node 1 cpus: 8 9 10 11 12 13 14 15
node 1 size: 32512 MB
node 1 free: 31930 MB
node 2 cpus: 16 17 18 19 20 21 22 23
node 2 size: 32512 MB
node 2 free: 31917 MB
node 3 cpus: 24 25 26 27 28 29 30 31
node 3 size: 32512 MB
node 3 free: 31928 MB
node 4 cpus: 32 33 34 35 36 37 38 39
node 4 size: 32512 MB
node 4 free: 31926 MB
node 5 cpus: 40 41 42 43 44 45 46 47
node 5 size: 32512 MB
node 5 free: 31913 MB
node 6 cpus: 48 49 50 51 52 53 54 55
node 6 size: 65280 MB
node 6 free: 63952 MB
node 7 cpus: 56 57 58 59 60 61 62 63
node 7 size: 65280 MB
node 7 free: 64230 MB
node distances:
node   0   1   2   3   4   5   6   7 
  0:  10  20  20  20  20  20  20  20 
  1:  20  10  20  20  20  20  20  20 
  2:  20  20  10  20  20  20  20  20 
  3:  20  20  20  10  20  20  20  20 
  4:  20  20  20  20  10  20  20  20 
  5:  20  20  20  20  20  10  20  20 
  6:  20  20  20  20  20  20  10  20 
  7:  20  20  20  20  20  20  20  10 



          KernelVersion:                 3.6.0-mainline_v36
                        Testcase:     Min      Max      Avg
                          numa01: 1509.14  2098.75  1793.90
                numa01_HARD_BIND:  865.43  1826.40  1334.85
             numa01_INVERSE_BIND: 3242.76  3496.71  3345.12
             numa01_THREAD_ALLOC:  944.28  1418.78  1214.32
   numa01_THREAD_ALLOC_HARD_BIND:  696.33  1004.99   825.63
numa01_THREAD_ALLOC_INVERSE_BIND: 2072.88  2301.27  2186.33
                          numa02:  129.87   146.10   136.88
                numa02_HARD_BIND:   25.81    26.18    25.97
             numa02_INVERSE_BIND:  341.96   354.73   345.59
                      numa02_SMT:  160.77   246.66   186.85
            numa02_SMT_HARD_BIND:   25.77    38.86    33.57
         numa02_SMT_INVERSE_BIND:  282.61   326.76   296.44

          KernelVersion:               3.6.0-autonuma27+                            
                        Testcase:     Min      Max      Avg  %Change   
                          numa01: 1805.19  1907.11  1866.39    -3.88%  
                numa01_HARD_BIND:  953.33  2050.23  1603.29   -16.74%  
             numa01_INVERSE_BIND: 3515.14  3882.10  3715.28    -9.96%  
             numa01_THREAD_ALLOC:  323.50   362.17   348.81   248.13%  
   numa01_THREAD_ALLOC_HARD_BIND:  841.08  1205.80   977.43   -15.53%  
numa01_THREAD_ALLOC_INVERSE_BIND: 2268.35  2654.89  2439.51   -10.38%  
                          numa02:   51.64    73.35    58.88   132.47%  
                numa02_HARD_BIND:   25.23    26.31    25.93     0.15%  
             numa02_INVERSE_BIND:  338.39   355.70   344.82     0.22%  
                      numa02_SMT:   51.76    66.78    58.63   218.69%  
            numa02_SMT_HARD_BIND:   34.95    45.39    39.24   -14.45%  
         numa02_SMT_INVERSE_BIND:  287.85   300.82   295.80     0.22%  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
