Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l81BYCvl018193
	for <linux-mm@kvack.org>; Sat, 1 Sep 2007 21:34:12 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l81BYBrs4153434
	for <linux-mm@kvack.org>; Sat, 1 Sep 2007 21:34:11 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l81CYB9H032561
	for <linux-mm@kvack.org>; Sat, 1 Sep 2007 22:34:11 +1000
Message-ID: <46D94E2E.5030605@linux.vnet.ibm.com>
Date: Sat, 01 Sep 2007 17:04:06 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] x86: Convert cpu_sibling_map to be a per cpu variable
 (v2)
References: <20070824222654.687510000@sgi.com> <20070824222948.851896000@sgi.com> <20070831194903.5d88a007.akpm@linux-foundation.org>
In-Reply-To: <20070831194903.5d88a007.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: travis@sgi.com, Andi Kleen <ak@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 24 Aug 2007 15:26:57 -0700 travis@sgi.com wrote:
>
>   
>> Convert cpu_sibling_map from a static array sized by NR_CPUS to a
>> per_cpu variable.  This saves sizeof(cpumask_t) * NR unused cpus.
>> Access is mostly from startup and CPU HOTPLUG functions.
>>     
>
> ia64 allmodconfig:
>
> kernel/sched.c: In function `cpu_to_phys_group':                                                                             kernel/sched.c:5937: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:5937: error: (Each undeclared identifier is reported only once
> kernel/sched.c:5937: error: for each function it appears in.)                                                                kernel/sched.c:5937: warning: type defaults to `int' in declaration of `type name'
> kernel/sched.c:5937: error: invalid type argument of `unary *'                                                               kernel/sched.c: In function `build_sched_domains':                                                                           kernel/sched.c:6172: error: `per_cpu__cpu_sibling_map' undeclared (first use in this function)                               kernel/sched.c:6172: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6172: error: invalid type argument of `unary *'                                                               kernel/sched.c:6183: warning: type defaults to `int' in declaration of `type name'                                           kernel/sched.c:6183: error: invalid type argument of `unary *'                                                               
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>
>   
Hi Andrew,

I get the exact build failure on ppc64 machine with 2.6.23-rc4-mm1.

-
Kamalesh Babulal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
