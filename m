Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5B96B020A
	for <linux-mm@kvack.org>; Fri, 14 May 2010 04:10:49 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id o4E87cTR009837
	for <linux-mm@kvack.org>; Fri, 14 May 2010 13:37:38 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4E87cnG3383532
	for <linux-mm@kvack.org>; Fri, 14 May 2010 13:37:38 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4E87bNa017752
	for <linux-mm@kvack.org>; Fri, 14 May 2010 18:07:38 +1000
Date: Fri, 14 May 2010 13:37:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC,2/7] NUMA Hotplug emulator
Message-ID: <20100514080732.GC3296@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100513114544.GC2169@shaohui>
 <20100514111615.c7ca63a5.kamezawa.hiroyu@jp.fujitsu.com>
 <20100514054226.GB12002@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100514054226.GB12002@linux-sh.org>
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shaohui Zheng <shaohui.zheng@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, ak@linux.intel.co, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

* Paul Mundt <lethal@linux-sh.org> [2010-05-14 14:42:26]:

> On Fri, May 14, 2010 at 11:16:15AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 13 May 2010 19:45:44 +0800
> > Shaohui Zheng <shaohui.zheng@intel.com> wrote:
> > 
> > > x86: infrastructure of NUMA hotplug emulation
> > > 
> > 
> > Hmm. do we have to create this for x86 only ?
> > Can't we live with lmb ? as
> > 
> > 	lmb_hide_node() or some.
> > 
> > IIUC, x86-version lmb is now under development.
> > 
> Indeed. There is very little x86-specific about this patch series at all
> except for the e820 bits and tying in the CPU topology. Most of what this
> series is doing wrapping around e820 could be done on top of LMB, which
> would also make it possible to use on non-x86 architectures.
>

Yes, that would be very nice addition 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
