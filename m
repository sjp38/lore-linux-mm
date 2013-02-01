Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 74A476B0029
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 22:06:32 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fa1so2043733pad.35
        for <linux-mm@kvack.org>; Thu, 31 Jan 2013 19:06:31 -0800 (PST)
Message-ID: <1359687985.1303.15.camel@kernel>
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
From: Simon Jeons <simon.jeons@gmail.com>
Date: Thu, 31 Jan 2013 21:06:25 -0600
In-Reply-To: <510B2B8A.7040407@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	       <1359463973.1624.15.camel@kernel> <5108F2B3.3090506@cn.fujitsu.com>
	      <1359595344.1557.13.camel@kernel> <5109E59F.5080104@cn.fujitsu.com>
	     <1359613162.1587.0.camel@kernel> <510A18FA.2010107@cn.fujitsu.com>
	    <1359622123.1391.19.camel@kernel> <510A3CE6.202@cn.fujitsu.com>
	   <1359628705.2048.5.camel@kernel> <510B1B4B.5080207@huawei.com>
	  <1359682576.3574.1.camel@kernel> <510B20F9.10408@cn.fujitsu.com>
	 <1359685040.1303.6.camel@kernel> <510B2B8A.7040407@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Tang,
On Fri, 2013-02-01 at 10:42 +0800, Tang Chen wrote:

I confuse!

> Hi Simon,
> 
> On 02/01/2013 10:17 AM, Simon Jeons wrote:
> >> For example:
> >>
> >>                                          64TB, what ever
> >>      xxxTB, what ever
> >> logic address space:     |_____kernel_______|_________user_________________|
> >>                                          \  \  /  /
> >>                                           \  /\  /
> >> physical address space:              |___\/__\/_____________|  4GB or
> >> 8GB, what ever
> >>                                             *****
> >
> > How much address space user process can have on x86_64? Also 8GB?
> 
> Usually, we don't say that.
> 
> 8GB is your physical memory, right ?
> But kernel space and user space is the logic conception in OS. They are 
> in logic
> address space.
> 
> So both the kernel space and the user space can use all the physical memory.
> But if the page is already in use by either of them, the other one 
> cannot use it.
> For example, some pages are direct mapped to kernel, and is in use by 
> kernel, the
> user space cannot map it.

How can distinguish map and use? I mean how can confirm memory is used
by kernel instead of map? 

> 
> >
> >>
> >> The ***** part physical is mapped to user space in the process' own
> >> pagetable.
> >> It is also direct mapped in kernel's pagetable. So the kernel can also
> >> access it. :)
> >
> > But how to protect user process not modify kernel memory?
> 
> This is the job of CPU. On intel cpus, user space code is running in 
> level 3, and
> kernel space code is running in level 0. So the code in level 3 cannot 
> access the data
> segment in level 0.

1) If user process and kenel map to same physical memory, user process
will get SIGSEGV during #PF if access to this memory, but If user proces
s will map to the same memory which kernel map? Why? It can't access it.
2) If two user processes map to same physical memory, what will happen
if one process access the memory?

> 
> Thanks. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
