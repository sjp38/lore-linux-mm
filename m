Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 913776B01E3
	for <linux-mm@kvack.org>; Sun, 16 May 2010 08:18:02 -0400 (EDT)
Date: Fri, 7 May 2010 16:11:42 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC,5/7] NUMA hotplug emulator
Message-ID: <20100507141142.GA8696@ucw.cz>
References: <20100513115625.GF2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513115625.GF2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Yinghai Lu <yinghai@kernel.org>, Thomas Renninger <trenn@suse.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>, Alex Chiang <achiang@hp.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Shaohua Li <shaohua.li@intel.com>, Jean Delvare <khali@linux-fr.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-acpi@vger.kernel.org, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Hi!

> hotplug emulator: Abstract cpu register functions
> 
> Abstract function arch_register_cpu and register_cpu, move the implementation
> details to a sub function with prefix "__". 
> 
> each of the sub function has an extra parameter nid, it can be used to register
> CPU under a fake NUMA node, it is a reserved interface for cpu hotplug emulation
> (CPU PROBE/RELEASE) in x86.

I don't get it. CPU hotplug can already be tested using echo 0/1 >
online, and that works on 386. How is this different?

It seems to add some numa magic. Why is it important?

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
