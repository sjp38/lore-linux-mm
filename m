Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E009A6B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 11:36:20 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAJGOsjf019755
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 09:24:54 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id oAJGaCOW240902
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 09:36:12 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAJGaCrG032630
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 09:36:12 -0700
Subject: Re: [7/8,v3] NUMA Hotplug Emulator: extend memory probe interface
 to support NUMA
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20101119075119.GD3327@shaohui>
References: <20101117020759.016741414@intel.com>
	 <20101117021000.916235444@intel.com> <1290019807.9173.3789.camel@nimitz>
	 <20101119075119.GD3327@shaohui>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 19 Nov 2010 08:36:09 -0800
Message-ID: <1290184569.32329.1986.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-11-19 at 15:51 +0800, Shaohui Zheng wrote:
> the purpose of hotplug emulator is providing a possible solution for cpu/memory
> hotplug testing, the interface upgrading is not part of emulator. Let's forget
> configfs here. 

If it's just for testing, you're right, we probably shouldn't go to the
trouble of making a new interface.  At the same time, we shouldn't put
something in /sys or configfs that we're not committed to, long-term.

So, not to replace the memory probe file, but _only_ to drive the new
debug-only node hot-add, I think its appropriate place is debugfs.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
