Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4C86B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 17:34:23 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id wp4so5686747obc.2
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 14:34:22 -0800 (PST)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id co8si5631907oec.125.2014.01.31.14.34.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 14:34:22 -0800 (PST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sat, 1 Feb 2014 04:04:16 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id EE59BE0056
	for <linux-mm@kvack.org>; Sat,  1 Feb 2014 04:07:22 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0VMYHVx46792832
	for <linux-mm@kvack.org>; Sat, 1 Feb 2014 04:04:17 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0VMYDdW010112
	for <linux-mm@kvack.org>; Sat, 1 Feb 2014 04:04:13 +0530
Message-ID: <52EC23B0.6010206@linux.vnet.ibm.com>
Date: Sat, 01 Feb 2014 03:59:04 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [LSF/MM ATTEND] Memory Power Management
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


Hi,

I would like to attend the LSF/MM Summit and discuss about the ongoing work
on developing Memory Power Management technology in the Linux kernel. Main
memory can consume a significant amount of power in the system (upto even 40%).
Hence, memory is the next big target for power-management, and this technology
can benefit computer systems ranging from mobile phones and tablets, to server
systems that form the back-bone of cloud computing infrastructures.

I have designed 3 core changes to the Linux MM subsystem to support Memory
Power Management, namely 'Sorted Buddy Page Allocator' (to influence Page
Allocation), 'Targeted Memory Compaction mechanism' (to handle memory
fragmentation) and a 'Region Allocator' as a back-end to the Page Allocator
(to serve as an anti-fragmentation scheme that boosts the success rates of
targeted memory-region evacuation).

I had got the opportunity to discuss some of these designs and algorithms
at the Linux Kernel Summit last year, where I had also presented some
interesting power-savings numbers on IBM POWER 7 hardware.

At the moment, I'm working on evaluating the patchset on newer IBM server
platforms with POWER 8 processors, and playing with different memory region
configurations on server hardware and trying to adapt my MM algorithms to
work well with large memory region sizes and fewer number of memory regions.
I'm also looking at understanding the memory access behavior of applications
that use large chunks of memory, such as KVM VM instances, and working on
tuning my patchset accordingly. At the same time, I'm helping out folks from
the ARM ecosystem to try out this patchset on their embedded boards to
evaluate the benefits on their platforms.

I would like to present the designs and algorithms behind Memory Power
Management at the summit, along with newer power-savings and performance
numbers, and thereby convince the MM maintainers about the benefits of this
feature and the elegance of its implementation.

Thank you very much.

References:
----------

1. LWN articles about Memory Power Management:

   http://lwn.net/Articles/547439/
   http://lwn.net/Articles/568891/

2. v4 of my Memory Power Management patchset:
   http://lwn.net/Articles/568369/

3. Experimental results from my patchsets:
   http://article.gmane.org/gmane.linux.power-management.general/40336
   http://article.gmane.org/gmane.linux.power-management.general/38987

4. Articles on Phoronix.com covering Memory Power Management and its
   end-user benefits:
   http://www.phoronix.com/scan.php?page=news_item&px=MTM0NzU
   http://www.phoronix.com/scan.php?page=news_item&px=MTUxMjA

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
