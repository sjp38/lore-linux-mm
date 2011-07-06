Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 007E19000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 00:27:52 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p664NP7V005462
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 14:23:25 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p664QKBg1491022
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 14:26:21 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p664RmxV010190
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 14:27:48 +1000
Date: Wed, 6 Jul 2011 09:57:44 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 0/5] mm,debug: VM framework to capture memory reference
 pattern
Message-ID: <20110706042744.GA15861@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
 <64797.1309908804@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <64797.1309908804@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi,

On Tue, Jul 05, 2011 at 07:33:24PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 05 Jul 2011 13:52:34 +0530, Ankita Garg said:
> 
> > by default) and scans through all pages of the specified tasks (including
> > children/threads) running in the system. If the hardware reference bit in the
> > page table is set, then the page is marked as accessed over the last sampling
> > interval and the reference bit is cleared.
> 
> Does that cause any issues for other code in the mm subsystem that was
> expecting to use the reference bit for something useful? (Similarly, if other
> code in mm turns that bit *off* for its own reasons, does your code still
> produce useful results?)

At this point, the VM code does not use the reference bit for any
decision making, not even in the LRU. However, if the reference bit is
used later on, then this change will interfere with that logic.

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
