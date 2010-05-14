Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6CC446B01EF
	for <linux-mm@kvack.org>; Thu, 13 May 2010 22:13:47 -0400 (EDT)
Message-ID: <4BECB1CB.2030802@linux.intel.com>
Date: Fri, 14 May 2010 10:13:31 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
References: <20100513114835.GD2169@shaohui> <20100513165511.GB25212@suse.de> <1273773292.13285.7755.camel@nimitz>
In-Reply-To: <1273773292.13285.7755.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Greg KH <gregkh@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2010-05-13 at 09:55 -0700, Greg KH wrote:
>>> Add a sysfs entry "probe" under /sys/devices/system/node/:
>>>
>>>  - to show all fake offlined nodes:
>>>     $ cat /sys/devices/system/node/probe
>>>
>>>  - to hotadd a fake offlined node, e.g. nodeid is N:
>>>     $ echo N > /sys/devices/system/node/probe
>> As you are trying to add a new sysfs file, please create the matching
>> Documentation/ABI/ file as well.
>>
>> Also note that sysfs files are "one value per file", which I don't think
>> this file follows, right?
> 
> I think in this case, it was meant to be a list of acceptable parameters
> rather than a set of values, kinda like /sys/power/state.

Right.

> Instead, I guess we could have:
> 
> 	/sys/devices/system/node/probeable/3
> 	/sys/devices/system/node/probeable/43
> 	/sys/devices/system/node/probeable/65
> 	/sys/devices/system/node/probeable/5145
> 
> and the knowledge that you need to pick one of those to echo
> into /sys/devices/system/node/probe.

I think this way would make things complex if we just want to show user which node could be hotadded.

>  But, it's a lot more self
> explanatory if you 'cat /sys/devices/system/node/probe', and then pick
> one of those to echo back into the file.

agreed.

> Seems like a decent place to violate the "rule". :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
