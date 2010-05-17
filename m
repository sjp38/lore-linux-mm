Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5C34D6B01E3
	for <linux-mm@kvack.org>; Sun, 16 May 2010 22:42:24 -0400 (EDT)
Message-ID: <4BF0AD09.80404@linux.intel.com>
Date: Mon, 17 May 2010 10:42:17 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC,5/7] NUMA hotplug emulator
References: <20100513115625.GF2169@shaohui> <20100507141142.GA8696@ucw.cz> <20100516174502.GI2418@linux.vnet.ibm.com>
In-Reply-To: <20100516174502.GI2418@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Pavel Machek <pavel@ucw.cz>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Thomas Renninger <trenn@suse.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>, Alex Chiang <achiang@hp.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Shaohua Li <shaohua.li@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-acpi@vger.kernel.org, fengguang.wu@intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Paul E. McKenney wrote:
> On Fri, May 07, 2010 at 04:11:42PM +0200, Pavel Machek wrote:
>> Hi!
>>
>>> hotplug emulator: Abstract cpu register functions
>>>
>>> Abstract function arch_register_cpu and register_cpu, move the implementation
>>> details to a sub function with prefix "__". 
>>>
>>> each of the sub function has an extra parameter nid, it can be used to register
>>> CPU under a fake NUMA node, it is a reserved interface for cpu hotplug emulation
>>> (CPU PROBE/RELEASE) in x86.
>> I don't get it. CPU hotplug can already be tested using echo 0/1 >
>> online, and that works on 386. How is this different?

"echo 0/1 > online" is logical cpu online/offline.
The emulator intends to emulate physical add/remove of cpus.
They cover different code path.

You can get details of the terms via $KERN_SRC/Documentation/cpu-hotplug.txt.

>> It seems to add some numa magic. Why is it important?

In real world, numa affinity info of the cpus is required for physical cpu hotadd/remove
, which finally affects related data structures and code path. Emulator need the ability
to emulate it.

> My guess is that he wants to test the software surrounding NUMA on a
> non-NUMA (or different-NUMA) machine, perhaps in order to shake out bugs
> before the corresponding hardware is available.

This is one of the purposes. Auto tests and debugging all can get benefits from such emulation.


-haicheng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
