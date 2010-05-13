Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B94A06B021E
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:11:29 -0400 (EDT)
Date: Thu, 13 May 2010 14:11:20 +0200
From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [RFC,5/7] NUMA hotplug emulator
Message-ID: <20100513141120.10524f05@hyperion.delvare>
In-Reply-To: <20100513115625.GF2169@shaohui>
References: <20100513115625.GF2169@shaohui>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Thomas Renninger <trenn@suse.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>, Alex Chiang <achiang@hp.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Shaohua Li <shaohua.li@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-acpi@vger.kernel.org, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 May 2010 19:56:25 +0800, Shaohui Zheng wrote:
> 
> hotplug emulator: Abstract cpu register functions
> 
> Abstract function arch_register_cpu and register_cpu, move the implementation
> details to a sub function with prefix "__". 
> 
> each of the sub function has an extra parameter nid, it can be used to register
> CPU under a fake NUMA node, it is a reserved interface for cpu hotplug emulation
> (CPU PROBE/RELEASE) in x86.
> 
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> Signed-off-by: Haicheng Li <haicheng.li@intel.com>

I don't know anything about this, please don't Cc me on these patches.
Given the very long Cc list, I'm certain many other developers you have
included are not interested. Please focus on the relevant lists next
time!

-- 
Jean Delvare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
