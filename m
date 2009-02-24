Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 18C7B6B00CD
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 14:46:55 -0500 (EST)
Date: Tue, 24 Feb 2009 11:46:53 -0800 (PST)
From: SANDYA MANNARSWAMY <sandyasm@yahoo.com>
Reply-To: sandyasm@yahoo.com
Subject: how to find the set of pages accessed by each thread in a process during a time window
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Message-ID: <500621.38863.qm@web65603.mail.ac4.yahoo.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

we are studying thread scheduling based on data access affinity on linux X-86 multicore systems. Basically if we can group threads of an application based on the affinity to the data they access, we would like to have them scheduled on the same processor so that they can use the shared caches in X86. There has been a number of papers in this area, both in academic and industry. Many of them are based on using the processor hardware counters  information to derive the information on data affinity for the threads.

We are looking at deriving a coarser level affinity information by looking at the set of VM pages accessed by each thread during a time window. Basically if we can dump out the set of pages accessed by each thread during a time window, we wanted to correlate that information across threads to see if we can derive a coarse affinity information for the threads. We are not interested in the physical page details per se, corresponding to the virtual page, but more in obtaining information/stats on which VM data pages of a process are accessed by each thread during each time window. 

I wanted to find out on whether there are any existing linux tools which provide this information. Should we try and gather this information by looking at the reference bit of each page table entry or is there a better way to go about it? 

Thanks in advance,
regards
sandya


      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
