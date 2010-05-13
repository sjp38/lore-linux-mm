Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2536B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 14:49:52 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4DIhTnY011641
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:43:29 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4DInfru037148
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:49:43 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4DBndgW008030
	for <linux-mm@kvack.org>; Thu, 13 May 2010 05:49:40 -0600
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100513181539.GA26597@suse.de>
References: <20100513120016.GG2169@shaohui> <20100513165603.GC25212@suse.de>
	 <1273773737.13285.7771.camel@nimitz>  <20100513181539.GA26597@suse.de>
Content-Type: text/plain
Date: Thu, 13 May 2010 11:49:38 -0700
Message-Id: <1273776578.13285.7820.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-13 at 11:15 -0700, Greg KH wrote:
> >       echo "physical_address=0x40000000 numa_node=3" > memory/probe
> > 
> > I'd *GREATLY* prefer that over this new syntax.  The existing mechanism
> > is obtuse enough, and the ',3' makes it more so.
> > 
> > We should have the code around to parse arguments like that, too, since
> > we use it for the boot command-line.
> 
> If you are going to be doing something like this, please use configfs,
> that is what it is designed for, not sysfs.

That's probably a really good point, especially since configfs didn't
even exist when we made this 'probe' file thingy.  It never was a great
fit for sysfs anyway.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
