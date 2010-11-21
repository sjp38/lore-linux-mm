Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 284306B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 10:00:45 -0500 (EST)
Received: by gxk7 with SMTP id 7so4015598gxk.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 07:00:42 -0800 (PST)
Date: Sun, 21 Nov 2010 23:03:45 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [8/8,v3] NUMA Hotplug Emulator: documentation
Message-ID: <20101121150344.GK9099@hack>
References: <20101117020759.016741414@intel.com> <20101117021000.985643862@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117021000.985643862@intel.com>
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 10:08:07AM +0800, shaohui.zheng@intel.com wrote:
>+2) CPU hotplug emulation:
>+
>+The emulator reserve CPUs throu grub parameter, the reserved CPUs can be
>+hot-add/hot-remove in software method, it emulates the process of physical
>+cpu hotplug.
>+
>+When hotplug a CPU with emulator, we are using a logical CPU to emulate the CPU
>+socket hotplug process. For the CPU supported SMT, some logical CPUs are in the
>+same socket, but it may located in different NUMA node after we have emulator.
>+We put the logical CPU into a fake CPU socket, and assign it an unique
>+phys_proc_id. For the fake socket, we put one logical CPU in only.
>+
>+ - to hide CPUs
>+	- Using boot option "maxcpus=N" hide CPUs
>+	  N is the number of initialize CPUs
>+	- Using boot option "cpu_hpe=on" to enable cpu hotplug emulation
>+      when cpu_hpe is enabled, the rest CPUs will not be initialized
>+
>+ - to hot-add CPU to node
>+	$ echo nid > cpu/probe
>+
>+ - to hot-remove CPU
>+	$ echo nid > cpu/release
>+

Again, we already have software CPU hotplug,
i.e. /sys/devices/system/cpu/cpuX/online.

You need to pick up another name for this.

>From your documentation above, it looks like you are trying
to move one CPU between nodes?

>+	cpu_hpe=on/off
>+		Enable/disable cpu hotplug emulation with software method. when cpu_hpe=on,
>+		sysfs provides probe/release interface to hot add/remove cpu dynamically.
>+		this option is disabled in default.
>+			

Why not just a CONFIG? IOW, why do we need to make another boot
parameter for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
