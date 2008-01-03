Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m0340XU7013733
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 15:00:33 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0340JJB3674262
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 15:00:19 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m03402eG002006
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 15:00:03 +1100
Date: Thu, 3 Jan 2008 09:29:42 +0530
From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
Message-ID: <20080103035942.GB26166@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
References: <20071215104434.GA26325@linux.vnet.ibm.com> <20071217045904.GB31386@linux.vnet.ibm.com> <Pine.LNX.4.64.0712171143280.12871@schroedinger.engr.sgi.com> <20071217120720.e078194b.akpm@linux-foundation.org> <Pine.LNX.4.64.0712171222470.29500@schroedinger.engr.sgi.com> <20071221044508.GA11996@linux.vnet.ibm.com> <Pine.LNX.4.64.0712261258050.16862@schroedinger.engr.sgi.com> <20071228101109.GB5083@linux.vnet.ibm.com> <Pine.LNX.4.64.0801021237330.21526@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801021346580.3778@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801021346580.3778@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, htejun@gmail.com, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, maneesh@linux.vnet.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 02, 2008 at 01:54:12PM -0800, Christoph Lameter wrote:
> Just traced it again on my system: It is okay for the number of pages on 
> the quicklist to reach the high count that we see (although the 16 bit 
> limits are weird. You have around 4GB of memory in the system?). Up to 
> 1/16th of free memory of a node can be allocated for quicklists (this 
> allows the effective shutting down and restarting of large amounts of 
> processes)
> 
> The problem may be that this is run on a HIGHMEM system and the 
> calculation of allowable pages on the quicklists does not take into 
> account that highmem pages are not usable for quicklists (not sure about 
> ZONE_MOVABLE on i386. Maybe we need to take that into account as well?)
> 
> Here is a patch that removes the HIGHMEM portion from the calculation. 
> Does this change anything:
> 

Yep. This one hits it. I don't see the obvious signs of the oom
happening in the 5 mins I have run the script. I will let it run for
some more time.

Thanks!
-- 
regards,
Dhaval

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
