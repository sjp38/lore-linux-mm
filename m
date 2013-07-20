Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4D2CA6B0031
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 09:02:32 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Sat, 20 Jul 2013 18:25:44 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 1BA9AE0054
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 18:32:22 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6KD3CxL20775030
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 18:33:13 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6KD2Nep005577
	for <linux-mm@kvack.org>; Sat, 20 Jul 2013 23:02:24 +1000
Message-ID: <51EA8C23.5070408@linux.vnet.ibm.com>
Date: Sat, 20 Jul 2013 18:39:55 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RESEND][PATCH] mm: vmstats: tlb flush counters
References: <20130716234438.C792C316@viggo.jf.intel.com> <CAC4Lta1mHixqfRSJKpydH3X9M_nQPCY3QSD86Tm=cnQ+KxpGYw@mail.gmail.com> <51E95932.5030902@sr71.net>
In-Reply-To: <51E95932.5030902@sr71.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Raghavendra KT <raghavendra.kt.linux@gmail.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 07/19/2013 08:50 PM, Dave Hansen wrote:
> On 07/19/2013 04:38 AM, Raghavendra KT wrote:
>> While measuring non - PLE performance, one of the bottleneck, I am seeing is
>> flush tlbs.
>> perf had helped in alaysing a bit there, but this patch would help
>> in precise calculation. It will aslo help in tuning the PLE window
>> experiments (larger PLE window
>> would affect remote flush TLBs)
>
> Interesting.  What workload is that?  I've been having problems finding
> workloads that are too consumed with TLB flushes.
>

Dave,
ebizzy is the one. and dbench to some small extent.

[root@codeblue ~]# cat /proc/vmstat  |grep nr_tlb ; 
/root/data/script/do_ebizzy.sh;  cat /proc/vmstat  |grep nr_tlb
nr_tlb_remote_flush 721
nr_tlb_remote_flush_received 923
nr_tlb_local_flush_all 13992
nr_tlb_local_flush_one 0
nr_tlb_local_flush_one_kernel 0
7482 records/s
real 120.00 s
user 86.69 s
sys  3746.57 s
nr_tlb_remote_flush 912896
nr_tlb_remote_flush_received 28261974
nr_tlb_local_flush_all 926272
nr_tlb_local_flush_one 0
nr_tlb_local_flush_one_kernel 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
