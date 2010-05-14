Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8F8576B01E3
	for <linux-mm@kvack.org>; Fri, 14 May 2010 01:50:19 -0400 (EDT)
Date: Fri, 14 May 2010 14:49:28 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC,5/7] NUMA hotplug emulator
Message-ID: <20100514054928.GC12002@linux-sh.org>
References: <20100513121457.GJ2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513121457.GJ2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 08:14:57PM +0800, Shaohui Zheng wrote:
> hotplug emulator: support cpu probe/release in x86
> 
> Add cpu interface probe/release under sysfs for x86. User can use this
> interface to emulate the cpu hot-add process, it is for cpu hotplug 
> test purpose. Add a kernel option CONFIG_ARCH_CPU_PROBE_RELEASE for this
> feature.
> 
> This interface provides a mechanism to emulate cpu hotplug with software
>  methods, it becomes possible to do cpu hotplug automation and stress
> testing.
> 
At a quick glance, is this really necessary? It seems like you could
easily replace most of this with a CPU notifier chain that takes care of
the node handling. See for example how ppc64 manages the CPU hotplug/numa
emulation case in arch/powerpc/mm/numa.c. arch_register_cpu() just looks
like some topology hack for ACPI, it would be nice not to perpetuate that
too much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
