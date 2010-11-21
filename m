Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A99946B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 19:55:38 -0500 (EST)
Date: Mon, 22 Nov 2010 07:33:51 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [8/8,v3] NUMA Hotplug Emulator: documentation
Message-ID: <20101121233351.GA7626@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.985643862@intel.com>
 <20101121150344.GK9099@hack>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101121150344.GK9099@hack>
Sender: owner-linux-mm@kvack.org
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 21, 2010 at 11:03:45PM +0800, Americo Wang wrote:
> On Wed, Nov 17, 2010 at 10:08:07AM +0800, shaohui.zheng@intel.com wrote:
> >+2) CPU hotplug emulation:
> >+
> >+The emulator reserve CPUs throu grub parameter, the reserved CPUs can be
> >+hot-add/hot-remove in software method, it emulates the process of physical
> >+cpu hotplug.
> >+
> >+When hotplug a CPU with emulator, we are using a logical CPU to emulate the CPU
> >+socket hotplug process. For the CPU supported SMT, some logical CPUs are in the
> >+same socket, but it may located in different NUMA node after we have emulator.
> >+We put the logical CPU into a fake CPU socket, and assign it an unique
> >+phys_proc_id. For the fake socket, we put one logical CPU in only.
> >+
> >+ - to hide CPUs
> >+	- Using boot option "maxcpus=N" hide CPUs
> >+	  N is the number of initialize CPUs
> >+	- Using boot option "cpu_hpe=on" to enable cpu hotplug emulation
> >+      when cpu_hpe is enabled, the rest CPUs will not be initialized
> >+
> >+ - to hot-add CPU to node
> >+	$ echo nid > cpu/probe
> >+
> >+ - to hot-remove CPU
> >+	$ echo nid > cpu/release
> >+
> 
> Again, we already have software CPU hotplug,
> i.e. /sys/devices/system/cpu/cpuX/online.
it is cpu online/offline in current kernel, not physical CPU hot-add or hot-remove.
the emulator is a tool to emulate the process of physcial CPU hotplug.
> 
> You need to pick up another name for this.
> 
> >From your documentation above, it looks like you are trying
> to move one CPU between nodes?
Yes, you are correct. With cpu probe/release interface, you can hot-remove a
CPU from a node, and hot-add it to another node.
> 
> >+	cpu_hpe=on/off
> >+		Enable/disable cpu hotplug emulation with software method. when cpu_hpe=on,
> >+		sysfs provides probe/release interface to hot add/remove cpu dynamically.
> >+		this option is disabled in default.
> >+			
> 
> Why not just a CONFIG? IOW, why do we need to make another boot
> parameter for this?
Only the developer or QA will use the emulator, we did not want to change the
default action for common user who does not care the hotplug emulator, so we
use a kernel parameter as a switch. The common user is not aware the existence
of the emulator.


-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
