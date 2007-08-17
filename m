Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7HFx7cs2343034
	for <linux-mm@kvack.org>; Sat, 18 Aug 2007 01:59:07 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7HFuHFF4239480
	for <linux-mm@kvack.org>; Sat, 18 Aug 2007 01:56:17 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7HFuGEC002090
	for <linux-mm@kvack.org>; Sat, 18 Aug 2007 01:56:17 +1000
Date: Fri, 17 Aug 2007 21:19:51 +0530
From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH 0/9] Memory controller introduction (v6)
Message-ID: <20070817154951.GA1393@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
References: <20070817084228.26003.12568.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070817084228.26003.12568.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 17, 2007 at 02:12:28PM +0530, Balbir Singh wrote:
Hi Andrew,
 
> The code was also tested on a power box with regular machine usage scenarios,
> the config disabled and with a stress suite that touched all the memory
> in the system and was limited in a container.
> 
> Dhaval ran several tests on v6 and gave his thumbs up to the controller
> (a hard to achieve goal :-) ).
> 

I've been running v6 on x86 and there are a few things I've tried. Most
of those results Balbir has already posted.

> Run kernbench stress
> --------------------
> Three simultaneously and with one inside a container of 800 MB.
> 

The idea here was to create pressure inside the container while having
global pressure.

> 
> Kernbench results running within the container of 800 MB
> --------------------------------------------------------
> 
> Thu Aug 16 22:34:59 IST 2007
> 2.6.23-rc2-mm2-mem-v6
> Average Half load -j 4 Run (std deviation):
> Elapsed Time 466.548 (47.6014)
> User Time 876.598 (10.5273)
> System Time 223.136 (1.29247)
> Percent CPU 237.2 (23.2744)
> Context Switches 146351 (6539.91)
> Sleeps 174003 (5031.94)
> 
> Average Optimal load -j 32 Run (std deviation):
> Elapsed Time 423.496 (60.625)
> User Time 897.285 (23.0391)
> System Time 228.836 (6.11205)
> Percent CPU 257.1 (40.9022)
> Context Switches 262134 (123397)
> Sleeps 270815 (103597)
> 
> 
> Kernbench results running within the default container
> ------------------------------------------------------
> 
> Thu Aug 16 22:34:33 IST 2007
> 2.6.23-rc2-mm2-mem-v6
> Average Half load -j 4 Run (std deviation):
> Elapsed Time 424.17 (3.45908)
> User Time 841.992 (5.40178)
> System Time 213.01 (0.706258)
> Percent CPU 248.2 (0.83666)
> Context Switches 134254 (9535.83)
> Sleeps 167359 (6858.45)
> 
> Average Optimal load -j 32 Run (std deviation):
> Elapsed Time 407.092 (108.932)
> User Time 878.493 (38.6575)
> System Time 222.155 (9.77127)
> Percent CPU 278.4 (91.5826)
> Context Switches 253836 (127708)
> Sleeps 263760 (103468)
> 
> 
> Kernbench results running within the default container
> ------------------------------------------------------
> 
> Thu Aug 16 22:34:52 IST 2007
> 2.6.23-rc2-mm2-mem-v6
> Average Half load -j 4 Run (std deviation):
> Elapsed Time 465.038 (48.5147)
> User Time 874.742 (5.86563)
> System Time 222.194 (0.561676)
> Percent CPU 237.2 (22.5211)
> Context Switches 144040 (7052.23)
> Sleeps 172130 (5608.73)
> 
> Average Optimal load -j 32 Run (std deviation):
> Elapsed Time 426.25 (62.34)
> User Time 893.938 (20.6732)
> System Time 227.717 (5.87502)
> Percent CPU 255.6 (40.7163)
> Context Switches 259560 (122953)
> Sleeps 267402 (101801)
> 

I've been running v6 for sometime and it has been stable (still not
been able to break/crash it, whereas v4 was broken within 1 hour :-) )

Andrew, I feel these patches whould be included in mm so that it gets
wider testing.

-- 
regards,
Dhaval

I would like to change the world but they don't give me the source code!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
