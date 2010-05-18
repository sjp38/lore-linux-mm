Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 496F76B01D1
	for <linux-mm@kvack.org>; Tue, 18 May 2010 11:46:20 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4IFWjTZ030663
	for <linux-mm@kvack.org>; Tue, 18 May 2010 11:32:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4IFkEET137052
	for <linux-mm@kvack.org>; Tue, 18 May 2010 11:46:14 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4IFkDw1008571
	for <linux-mm@kvack.org>; Tue, 18 May 2010 12:46:14 -0300
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4BF255F3.9040002@linux.intel.com>
References: <20100513120016.GG2169@shaohui> <20100513165603.GC25212@suse.de>
	 <1273773737.13285.7771.camel@nimitz> <20100513181539.GA26597@suse.de>
	 <1273776578.13285.7820.camel@nimitz>  <20100518054121.GA25298@shaohui>
	 <1274167625.17463.17.camel@nimitz>  <4BF255F3.9040002@linux.intel.com>
Content-Type: text/plain
Date: Tue, 18 May 2010 08:46:10 -0700
Message-Id: <1274197570.17463.30.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: Shaohui Zheng <shaohui.zheng@intel.com>, Greg KH <gregkh@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 2010-05-18 at 10:55 +0200, Andi Kleen wrote:
> I liked Dave's earlier proposal to do a command line parameter like interface
> for "probe". Perhaps that can be done. It shouldn't need a lot of code.

After looking at the code, configfs doesn't look to me like it can be
done horribly easily.  It takes a least a subsystem and then a few
structures to get things up and running.  There also doesn't appear to
be a good subsystem to plug into.

> In fact there are already two different parser libraries for this:
> lib/parser.c and lib/params.c. One could chose the one that one likes
> better :-)

Agreed.  But, I do see why Greg is suggesting configfs here.
Superficially, it seems like a good configfs fit, but I think configfs
is only a good fit when you need to cram a _bunch_ of stuff into a _new_
interface.  Here, we have a relatively tiny amount of data that has half
of what it needs from an existing interface.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
