Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id B8F3A6B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 13:13:20 -0500 (EST)
Message-ID: <509D47FF.2030005@linux.intel.com>
Date: Fri, 09 Nov 2012 10:14:23 -0800
From: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I did like this implementation and think it is valuable.
I am experimenting with one of our HW. This type of partition does help in
saving power. Our calculations shows significant saving of power per DIM with the help
of some HW/BIOS changes. We are only talking about content preserving memory,
so we don't have to be 100% correct.
In my experiments, I tried two methods:
- Similar to approach suggested by Mel Gorman. I have a special sticky
migrate type like CMA.
- Buddy buckets: Buddies are organized into memory region aware buckets.
During allocation it prefers higher order buckets. I made sure that there is
no affect of my change if there are no power saving memory DIMs. The advantage
of this bucket is that I can keep the memory in close proximity for a related
task groups by direct hashing to a bucket. The free list if organized as two
dimensional array with bucket and migrate type for each order.


In both methods, currently reclaim is targeted to be done by a sysfs interface
similar to memory compaction for a node allowing user space to initiate reclaim.



Thanks,
Srinivas Pandruvada
Open Source Technology Center,
Intel Corp.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
