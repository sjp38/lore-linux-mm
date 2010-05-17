Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A04B56B01F3
	for <linux-mm@kvack.org>; Mon, 17 May 2010 05:39:01 -0400 (EDT)
Message-ID: <4BF10EA8.9050904@linux.intel.com>
Date: Mon, 17 May 2010 11:38:48 +0200
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC,5/7] NUMA hotplug emulator
References: <20100513115625.GF2169@shaohui> <20100507141142.GA8696@ucw.cz>
In-Reply-To: <20100507141142.GA8696@ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Thomas Renninger <trenn@suse.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>, Alex Chiang <achiang@hp.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Shaohua Li <shaohua.li@intel.com>, Jean Delvare <khali@linux-fr.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-acpi@vger.kernel.org, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

, Pavel Machek wrote:
> Hi!
>
>> hotplug emulator: Abstract cpu register functions
>>
>> Abstract function arch_register_cpu and register_cpu, move the implementation
>> details to a sub function with prefix "__".
>>
>> each of the sub function has an extra parameter nid, it can be used to register
>> CPU under a fake NUMA node, it is a reserved interface for cpu hotplug emulation
>> (CPU PROBE/RELEASE) in x86.
>
> I don't get it. CPU hotplug can already be tested using echo 0/1>
> online, and that works on 386. How is this different?

It tests a different code path.

> It seems to add some numa magic. Why is it important?

It tests memory and node hotadd too. Memory/node hotadd is a quite problematic
feature and needs all the testing support it can get.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
