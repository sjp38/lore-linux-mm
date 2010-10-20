Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E4DA45F004B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:47:41 -0400 (EDT)
Subject: Re: oom_killer crash linux system
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
In-Reply-To: <20101020122137.1824.A69D9226@jp.fujitsu.com>
References: <20101020112828.1818.A69D9226@jp.fujitsu.com>
	 <1287543520.2074.1.camel@myhost>
	 <20101020122137.1824.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 11:43:45 +0800
Message-ID: <1287546225.2121.14.camel@myhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> > active_anon:398375 inactive_anon:82967 isolated_anon:0 
> >  active_file:81 inactive_file:429 isolated_file:32
> >  unevictable:13 dirty:2 writeback:14 unstable:0
> >  free:11942 slab_reclaimable:2391 slab_unreclaimable:3303
> >  mapped:5617 shmem:33909 pagetables:2280 bounce:0
> 
> active_anon + inactive_anon + isolated_anon = 481342 pages ~= 1.8GB
> Um, this oom doesn't makes accounting lost.
> 
> > here is the page-types log:
> >              flags	page-count       MB  symbolic-flags long-symbolic-flags
> > 
> > 0x0000000000005828	     83024      324 ___U_l_____Ma_b___________________ uptodate,lru,mmap,anonymous,swapbacked
> > 0x0000000000005868	    358737     1401 ___U_lA____Ma_b___________________ uptodate,lru,active,mmap,anonymous,swapbacked
> >              total	    515071     2011
> 
> page-types show similar result.
> 
> 
> The big difference is, previous and current are showing some different processes.
> only previous has VirtualBox, only current has vmware-usbarbit, etc..
> 
> Can you use same test environment?
yes, it is the same desktop, and i open some pdf files and applications
by random. 

but when my desktop eat up to 1.8GB RAM (active_anon + inactive_anon +
isolated_anon = 481342 pages >= 1.8GB), the system became extraordinary
slow. when i move the mouse, the mouse cant move a little on screen. i
deem it have "crashed", but i ping it's ip by other desktop, it is ok.

so what is apect affect the system seem to "crashed", page-writeback?
page-reclaimed?  and the oom-killer seem to be very conservative? in
that condition , oom_killer must kill some process to release memory for
new process.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
