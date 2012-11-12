Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 930156B005A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:15:55 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 13 Nov 2012 02:10:56 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qACGFeks60293154
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 03:15:45 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qACGFdF2016940
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 03:15:40 +1100
Message-ID: <50A12062.4070205@linux.vnet.ibm.com>
Date: Mon, 12 Nov 2012 21:44:26 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de> <loom.20121109T172910-394@post.gmane.org>
In-Reply-To: <loom.20121109T172910-394@post.gmane.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SrinivasPandruvada <srinivas.pandruvada@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, mjg59@srcf.ucam.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, Arjan van de Ven <arjan@linux.intel.com>, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@vger.kernel.org, Ankita Garg <gargankita@gmail.com>, amit.kachhap@linaro.org, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, thomas.abraham@linaro.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, andi@firstfloor.org

Hi Srinivas,

It looks like your email did not get delivered to the mailing
lists (and the people in the CC list) properly. So quoting your
entire mail as-it-is here. And thanks a lot for taking a look
at this patchset!

Regards,
Srivatsa S. Bhat

On 11/09/2012 10:18 PM, SrinivasPandruvada wrote:
> I did like this implementation and think it is valuable.
> I am experimenting with one of our HW. This type of partition does help in
> saving power. We believe we can save up-to 1W power per DIM with the help
> of some HW/BIOS changes. We are only talking about content preserving memory,
> so we don't have to be 100% correct.
> In my experiments, I tried two methods:
> - Similar to approach suggested by Mel Gorman. I have a special sticky
> migrate type like CMA.
> - Buddy buckets: Buddies are organized into memory region aware buckets.
> During allocation it prefers higher order buckets. I made sure that there is
> no affect of my change if there are no power saving memory DIMs. The advantage
> of this bucket is that I can keep the memory in close proximity for a related
> task groups by direct hashing to a bucket. The free list if organized as two
> dimensional array with bucket and migrate type for each order.
> 
> In both methods, currently reclaim is targetted to be done by a sysfs interface
> similar to memory compaction for a node allowing user space to initiate reclaim. 
> 
> Thanks,
> Srinivas Pandruvada
> Open Source Technology Center,
> Intel Corp.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
