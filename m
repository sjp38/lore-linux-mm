Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD2A8D0039
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 04:24:20 -0500 (EST)
Subject: Re: [Xen-devel] [PATCH R3 0/7] xen/balloon: Memory hotplug support
 for Xen balloon driver
From: Vasiliy G Tolstov <v.tolstov@selfip.ru>
Reply-To: v.tolstov@selfip.ru
In-Reply-To: <1296810682.13091.571.camel@zakaz.uk.xensource.com>
References: <20110203162345.GC1364@router-fw-old.local.net-space.pl>
	 <1296768009.2346.7.camel@mobile>
	 <1296810682.13091.571.camel@zakaz.uk.xensource.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Feb 2011 12:21:32 +0300
Message-ID: <1296811292.8588.3.camel@vase>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi.kleen@intel.com" <andi.kleen@intel.com>, "haicheng.li@linux.intel.com" <haicheng.li@linux.intel.com>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "jeremy@goop.org" <jeremy@goop.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, "pasik@iki.fi" <pasik@iki.fi>, "dave@linux.vnet.ibm.com" <dave@linux.vnet.ibm.com>, "wdauchy@gmail.com" <wdauchy@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2011-02-04 at 09:11 +0000, Ian Campbell wrote:
> On Thu, 2011-02-03 at 21:20 +0000, Vasiliy G Tolstov wrote:
> > I have some may be offtopic question: Is that possible to export balloon
> > function balloon_set_new_target to GPL modules (EXPORT_SYMBOL_GPL) ? 
> > This helps to kernel modules (not in kernel tree) to contol balloonin
> > (for example autoballoon or something else) without needing to write so
> > sysfs. (Writing files from kernel module is bad, this says Linux Kernel
> > Faq).
> 
> Is there a reason to do it from kernel space in the first place? auto
> ballooning can be done by a userspace daemon, can't it?
> 
> Ian.
> 

Yes. It can be done via userspace, but if i want to control autoballon
via sysfs/sysctl/procfs i need to write module. And i don't think that
export this function can break some stuff. Now i have autoballoon kernel
module that enlarge and shrinks memory. Userspace daemon need some
dependencies like glibc, libxenstore and others, but if i'm not provide
ability to chouse kernel (i'm boot domU via kernel and ramdisk), very
simple to add in ramdisk kernel module that says disk/memory usage and
controls memory ballooning.

-- 
Vasiliy G Tolstov <v.tolstov@selfip.ru>
Selfip.Ru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
