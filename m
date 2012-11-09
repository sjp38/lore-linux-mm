Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 98BFA6B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 11:35:36 -0500 (EST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 9 Nov 2012 22:05:31 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA9GZQtj15466744
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 22:05:27 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA9M54mP001295
	for <linux-mm@kvack.org>; Sat, 10 Nov 2012 09:05:07 +1100
Message-ID: <509D3088.2060507@linux.vnet.ibm.com>
Date: Fri, 09 Nov 2012 22:04:16 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de> <20121109051247.GA499@dirshya.in.ibm.com> <20121109090052.GF8218@suse.de> <509D185D.8070307@linux.vnet.ibm.com> <509D200F.2000908@linux.vnet.ibm.com> <509D2B9B.4090305@linux.vnet.ibm.com>
In-Reply-To: <509D2B9B.4090305@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/09/2012 09:43 PM, Dave Hansen wrote:
> On 11/09/2012 07:23 AM, Srivatsa S. Bhat wrote:
>> FWIW, kernbench is actually (and surprisingly) showing a slight performance
>> *improvement* with this patchset, over vanilla 3.7-rc3, as I mentioned in
>> my other email to Dave.
>>
>> https://lkml.org/lkml/2012/11/7/428
>>
>> I don't think I can dismiss it as an experimental error, because I am seeing
>> those results consistently.. I'm trying to find out what's behind that.
> 
> The only numbers in that link are in the date. :)  Let's see the
> numbers, please.
> 

Sure :) The reason I didn't post the numbers very eagerly was that I didn't
want it to look ridiculous if it later turned out to be really an error in the
experiment ;) But since I have seen it happening consistently I think I can
post the numbers here with some non-zero confidence.

> If you really have performance improvement to the memory allocator (or
> something else) here, then surely it can be pared out of your patches
> and merged quickly by itself.  Those kinds of optimizations are hard to
> come by!
> 

:-)

Anyway, here it goes:

Test setup:
----------
x86 2-socket quad-core machine. (CONFIG_NUMA=n because I figured that my
patchset might not handle NUMA properly). Mem region size = 512 MB.

Kernbench log for Vanilla 3.7-rc3
=================================

Kernel: 3.7.0-rc3-vanilla-default
Average Optimal load -j 32 Run (std deviation):
Elapsed Time 650.742 (2.49774)
User Time 8213.08 (17.6347)
System Time 1273.91 (6.00643)
Percent CPU 1457.4 (3.64692)
Context Switches 2250203 (3846.61)
Sleeps 1.8781e+06 (5310.33)

Kernbench log for this sorted-buddy patchset
============================================

Kernel: 3.7.0-rc3-sorted-buddy-default
Average Optimal load -j 32 Run (std deviation):
Elapsed Time 591.696 (0.660969)
User Time 7511.97 (1.08313)
System Time 1062.99 (1.1109)
Percent CPU 1448.6 (1.94936)
Context Switches 2.1496e+06 (3507.12)
Sleeps 1.84305e+06 (3092.67)

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
