Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 193AF6B0089
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 01:05:52 -0400 (EDT)
Received: by gwj21 with SMTP id 21so1948334gwj.14
        for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:05:51 -0700 (PDT)
Date: Wed, 20 Oct 2010 14:05:18 +0900
From: Adam Jiang <jiang.adam@gmail.com>
Subject: Re: oom_killer crash linux system
Message-ID: <20101020050518.GD5796@rcwf64-moto>
References: <20101020112828.1818.A69D9226@jp.fujitsu.com>
 <1287543520.2074.1.camel@myhost>
 <20101020122137.1824.A69D9226@jp.fujitsu.com>
 <1287546225.2121.14.camel@myhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1287546225.2121.14.camel@myhost>
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, figo1802 <figo1802@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 11:43:45AM +0800, Figo.zhang wrote:
> 
> > > active_anon:398375 inactive_anon:82967 isolated_anon:0 
> > >  active_file:81 inactive_file:429 isolated_file:32
> > >  unevictable:13 dirty:2 writeback:14 unstable:0
> > >  free:11942 slab_reclaimable:2391 slab_unreclaimable:3303
> > >  mapped:5617 shmem:33909 pagetables:2280 bounce:0
> > 
> > active_anon + inactive_anon + isolated_anon = 481342 pages ~= 1.8GB
> > Um, this oom doesn't makes accounting lost.
> > 
> > >              total	    515071     2011
> > 
> > page-types show similar result.
> > 
> > 
> > The big difference is, previous and current are showing some different processes.
> > only previous has VirtualBox, only current has vmware-usbarbit, etc..
> > 
> > Can you use same test environment?
> yes, it is the same desktop, and i open some pdf files and applications
> by random. 
> 
> but when my desktop eat up to 1.8GB RAM (active_anon + inactive_anon +
> isolated_anon = 481342 pages >= 1.8GB), the system became extraordinary
> slow. when i move the mouse, the mouse cant move a little on screen. i
> deem it have "crashed", but i ping it's ip by other desktop, it is ok.
> 
> so what is apect affect the system seem to "crashed", page-writeback?
> page-reclaimed?  and the oom-killer seem to be very conservative? in
> that condition , oom_killer must kill some process to release memory for
> new process.

I think it just simply the test caused system *almost* dead but not
really trigger oom-killer. You have 2GB RAM, right. 0.2G is a huge
amount of memory for Linux kernel.

If you do want to test the new oom-killer, you can just right a simple
program to allocate memory continues but make different instances to
eat memory in different paces. Then, you can find out who will be killed
first eventually.

/Adam
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
