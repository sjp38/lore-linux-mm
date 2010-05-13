Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 799476B01EF
	for <linux-mm@kvack.org>; Thu, 13 May 2010 15:17:09 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4DJ6sIL016293
	for <linux-mm@kvack.org>; Thu, 13 May 2010 13:06:54 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4DJGkqP034088
	for <linux-mm@kvack.org>; Thu, 13 May 2010 13:16:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4DJGjDL000842
	for <linux-mm@kvack.org>; Thu, 13 May 2010 13:16:46 -0600
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100513185844.GA5959@suse.de>
References: <20100513120016.GG2169@shaohui> <20100513165603.GC25212@suse.de>
	 <1273773737.13285.7771.camel@nimitz> <20100513181539.GA26597@suse.de>
	 <1273776578.13285.7820.camel@nimitz>  <20100513185844.GA5959@suse.de>
Content-Type: text/plain
Date: Thu, 13 May 2010 12:16:43 -0700
Message-Id: <1273778203.13285.7851.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-13 at 11:58 -0700, Greg KH wrote:
> > That's probably a really good point, especially since configfs didn't
> > even exist when we made this 'probe' file thingy.  It never was a great
> > fit for sysfs anyway.
> 
> Really?  configfs was added in 2.6.16, when was this probe file added?

$ git name-rev 3947be19
3947be19 tags/v2.6.15-rc1~728^2~12

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
