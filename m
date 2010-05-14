Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4714E6B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 21:54:08 -0400 (EDT)
Date: Fri, 14 May 2010 09:45:35 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
Message-ID: <20100514014535.GA4381@shaohui>
References: <20100513114835.GD2169@shaohui>
 <20100513165511.GB25212@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513165511.GB25212@suse.de>
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 09:55:11AM -0700, Greg KH wrote:
> On Thu, May 13, 2010 at 07:48:35PM +0800, Shaohui Zheng wrote:
> > Userland interface to hotplug-add fake offlined nodes.
> 
> Why include 2 copies of the patch in one email?
I always try to attach the patch as attachment, it is the same with the mail
content, I guess it should take convenience when you need to save the patch 
to local, it might be a bad habbit, I will be careful when I send patch next time.
thanks for the reminding.

> 
> > Add a sysfs entry "probe" under /sys/devices/system/node/:
> > 
> >  - to show all fake offlined nodes:
> >     $ cat /sys/devices/system/node/probe
> > 
> >  - to hotadd a fake offlined node, e.g. nodeid is N:
> >     $ echo N > /sys/devices/system/node/probe
> 
> As you are trying to add a new sysfs file, please create the matching
> Documentation/ABI/ file as well.

Agree, We will document it in.

> 
> Also note that sysfs files are "one value per file", which I don't think
> this file follows, right?

Agree, the cpu/probe interface should write only, and we should create another
file to indicate the hidden nodes, such as cpu/hidden. We will follow this rule
when we send the formal patch.

Thanks greg's comments so much, have a nice day.

> 
> thanks,
> 
> greg k-h

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
