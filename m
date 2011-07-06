Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 980209000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 05:31:59 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id p669VloK022319
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 15:01:47 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p669VlbL3715080
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 15:01:47 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p669Vl8g030831
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 19:31:47 +1000
Date: Wed, 6 Jul 2011 15:01:46 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 0/5] mm,debug: VM framework to capture memory reference
 pattern
Message-ID: <20110706093146.GB19518@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
 <20110706020103.53ed8706.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110706020103.53ed8706.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Hi,

On Wed, Jul 06, 2011 at 02:01:03AM -0700, Andrew Morton wrote:
> On Tue,  5 Jul 2011 13:52:34 +0530 Ankita Garg <ankita@in.ibm.com> wrote:
> 
> > 
> > This patch series is an instrumentation/debug infrastructure that captures
> > the memory reference pattern of applications (workloads). 
> 
> Can't the interfaces described in Documentation/vm/pagemap.txt be used
> for this?

The pagemap interface does not closely track the hardware reference bit
of the pages. The 'REFERENCED' flag maintained in /proc/kpageflags
only indicates if the page has been referenced since last LRU list
enqueue/requeue. So estimating the rate at which a particular page of
memory is referenced cannot be obtained. Further, it does not provide
information on the amount of kernel memory referenced on behalf of
the process.

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
