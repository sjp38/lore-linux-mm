Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F3B376B0087
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 01:35:32 -0500 (EST)
Date: Thu, 23 Dec 2010 13:10:47 +0800
From: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Subject: Re: [6/7, v9] NUMA Hotplug Emulator: Fake CPU socket with logical
 CPU on x86
Message-ID: <20101223051047.GA13060@shaohui>
References: <20101210073119.156388875@intel.com>
 <20101210073242.773689101@intel.com>
 <20101222162732.bef6904e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101222162732.bef6904e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: shaohui.zheng@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Sam Ravnborg <sam@ravnborg.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 22, 2010 at 04:27:32PM -0800, Andrew Morton wrote:
> >  static struct task_struct *idle_thread_array[NR_CPUS] __cpuinitdata ;
> > @@ -198,6 +200,8 @@
> >  {
> >  	int cpuid, phys_id;
> >  	unsigned long timeout;
> > +	u8 cpu_probe_on = 0;
> 
> Unneeded initialisation.
> 
> Does this cause an unused var warning when
> CONFIG_ARCH_CPU_PROBE_RELEASE=n?
> 

I am trying to avoid too much ifdef here, it seems it take an unused var
warining when CONFIG_ARCH_CPU_PROBE_RELEASE=n. good catching.

I will figure out a better method.

> > +	struct cpuinfo_x86 *c;
> >  
> >  	/*
> >  	 * If waken up by an INIT in an 82489DX configuration
> >
> > ...
> >
> > +#ifdef CONFIG_ARCH_CPU_PROBE_RELEASE
> > +/*
> > + * Put the logical cpu into a new sokect, and encapsule it into core 0.
> 
> That comment needs help.
> 

Agree, the comment is too simple, should add better documents for function
fake_cpu_socket_info.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
