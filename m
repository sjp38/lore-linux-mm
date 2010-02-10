Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 988E36B004D
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 22:53:16 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id o1A3HH3K007200
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 08:47:17 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1A3rBNQ2859130
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 09:23:11 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1A3rBvs005606
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 14:53:11 +1100
Date: Wed, 10 Feb 2010 09:20:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
Message-ID: <20100210035052.GH3290@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <4B71927D.6030607@nortel.com>
 <20100210093140.12D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100210093140.12D9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Chris Friesen <cfriesen@nortel.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-02-10 09:32:07]:

> > Hi,
> > 
> > I'm hoping you can help me out.  I'm on a 2.6.27 x86 system and I'm
> > seeing the "inactive" field in /proc/meminfo slowly growing over time to
> > the point where eventually the oom-killer kicks in and starts killing
> > things.  The growth is not evident in any other field in /proc/meminfo.
> > 
> > I'm trying to figure out where the memory is going, and what it's being
> > used for.
> > 
> > As I've found, the fields in /proc/meminfo don't add up...in particular,
> > active+inactive is quite a bit larger than
> > buffers+cached+dirty+anonpages+mapped+pagetables+vmallocused.  Initially
> > the difference is about 156MB, but after about 13 hrs the difference is
> > 240MB.
> > 
> > How can I track down where this is going?  Can you suggest any
> > instrumentation that I can add?
> > 
> > I'm reasonably capable, but I'm getting seriously confused trying to
> > sort out the memory subsystem.  Some pointers would be appreciated.
> 
> can you please post your /proc/meminfo?
>

Do you have swap enabled? Can you help with the OOM killed dmesg log?
Does the situation get better after OOM killing. /proc/meminfo as
Kosaki suggested would be important as well. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
