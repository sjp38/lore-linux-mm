Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6304F6B0239
	for <linux-mm@kvack.org>; Thu, 13 May 2010 12:59:36 -0400 (EDT)
Date: Thu, 13 May 2010 09:55:11 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
Message-ID: <20100513165511.GB25212@suse.de>
References: <20100513114835.GD2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513114835.GD2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 07:48:35PM +0800, Shaohui Zheng wrote:
> Userland interface to hotplug-add fake offlined nodes.

Why include 2 copies of the patch in one email?

> Add a sysfs entry "probe" under /sys/devices/system/node/:
> 
>  - to show all fake offlined nodes:
>     $ cat /sys/devices/system/node/probe
> 
>  - to hotadd a fake offlined node, e.g. nodeid is N:
>     $ echo N > /sys/devices/system/node/probe

As you are trying to add a new sysfs file, please create the matching
Documentation/ABI/ file as well.

Also note that sysfs files are "one value per file", which I don't think
this file follows, right?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
