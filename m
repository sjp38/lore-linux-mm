Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A82596B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 13:55:17 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o4DHrZaI030134
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:53:35 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4DHt0kJ092094
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:55:00 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4DHstgx028978
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:54:56 -0600
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100513165511.GB25212@suse.de>
References: <20100513114835.GD2169@shaohui> <20100513165511.GB25212@suse.de>
Content-Type: text/plain
Date: Thu, 13 May 2010 10:54:52 -0700
Message-Id: <1273773292.13285.7755.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <gregkh@suse.de>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 2010-05-13 at 09:55 -0700, Greg KH wrote:
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
> 
> Also note that sysfs files are "one value per file", which I don't think
> this file follows, right?

I think in this case, it was meant to be a list of acceptable parameters
rather than a set of values, kinda like /sys/power/state.  Instead, I
guess we could have:

	/sys/devices/system/node/probeable/3
	/sys/devices/system/node/probeable/43
	/sys/devices/system/node/probeable/65
	/sys/devices/system/node/probeable/5145

and the knowledge that you need to pick one of those to echo
into /sys/devices/system/node/probe.  But, it's a lot more self
explanatory if you 'cat /sys/devices/system/node/probe', and then pick
one of those to echo back into the file.

Seems like a decent place to violate the "rule". :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
