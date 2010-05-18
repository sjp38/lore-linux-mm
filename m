Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 976786B01E3
	for <linux-mm@kvack.org>; Tue, 18 May 2010 03:27:16 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4I7PFo1025787
	for <linux-mm@kvack.org>; Tue, 18 May 2010 03:25:15 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4I7R999123766
	for <linux-mm@kvack.org>; Tue, 18 May 2010 03:27:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4I7R8N6018039
	for <linux-mm@kvack.org>; Tue, 18 May 2010 03:27:09 -0400
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100518054121.GA25298@shaohui>
References: <20100513120016.GG2169@shaohui> <20100513165603.GC25212@suse.de>
	 <1273773737.13285.7771.camel@nimitz> <20100513181539.GA26597@suse.de>
	 <1273776578.13285.7820.camel@nimitz>  <20100518054121.GA25298@shaohui>
Content-Type: text/plain
Date: Tue, 18 May 2010 00:27:05 -0700
Message-Id: <1274167625.17463.17.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Greg KH <gregkh@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 2010-05-18 at 13:41 +0800, Shaohui Zheng wrote:
> On Thu, May 13, 2010 at 11:49:38AM -0700, Dave Hansen wrote:
> the configfs was introduced in 2005, you can refer to http://lwn.net/Articles/148973/.
> 
> I enabled the configfs, and I see that the configfs is not so popular as we expected,
> I mount configfs to /sys/kernel/config, I get an empty directory. It means that nobody is 
> using this file system, it is an interesting thing, is it means that configfs is deprecated?
> If so, it might not be nessarry to develop a configfs interface for hotplug.

Uh, deprecated?  What would make you think that?  It does look like the
users are a we bit obscure, but that's a bit far from deprecated.

> Dave & Greg,
> 	Can you provide an exmample to use configfs as interface in Linux kernel, I want to get
> a live demo, thanks.

Heh.  There are some great tools out there called cscope and grep.  I
have them on my system and I bet you can get them on yours too.

That said, you're right.  There don't seem to be a ton of users of it
these days.  But, the LWN article you referenced also pointed to at
least one user.  So, please try and put a wee bit of effort into it.

Maybe configfs isn't the way to go.  I just think extending the 'probe'
file is a bad idea, especially in the way your patch did it.  I'm open
to other alternatives.  Since this is only for testing, perhaps debugfs
applies better.  What other alternatives have you explored?  How about a
Systemtap set to do it? :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
