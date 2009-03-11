Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F27F86B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 13:16:51 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2BHGguZ024565
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 22:46:42 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2BHDVAs4133074
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 22:43:31 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2BHGftt020640
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:16:41 +1100
Date: Wed, 11 Mar 2009 22:46:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] use css id in swap cgroup for saving memory v5
Message-ID: <20090311171637.GF16769@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp> <20090310160856.77deb5c3.akpm@linux-foundation.org> <20090311085326.403a211d.kamezawa.hiroyu@jp.fujitsu.com> <isapiwc.d14e3c29.6b18.49b7092b.9bc73.52@mail.jp.nec.com> <20090311094739.3123b05d.kamezawa.hiroyu@jp.fujitsu.com> <20090311120427.2467bd14.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0903111041260.16964@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903111041260.16964@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2009-03-11 11:05:55]:

> Sorry, you'd prefer my input on the rest, which I've not studied, but ...
> 
> On Wed, 11 Mar 2009, KAMEZAWA Hiroyuki wrote:
> ...
> >  
> > @@ -432,7 +428,7 @@ int swap_cgroup_swapon(int type, unsigne
> >  
> >  	printk(KERN_INFO
> >  		"swap_cgroup: uses %ld bytes of vmalloc for pointer array space"
> > -		" and %ld bytes to hold mem_cgroup pointers on swap\n",
> > +		" and %ld bytes to hold mem_cgroup information per swap ents\n",
> >  		array_size, length * PAGE_SIZE);
> >  	printk(KERN_INFO
> >  	"swap_cgroup can be disabled by noswapaccount boot option.\n");
> 
> ... I do get very irritated by all the screenspace these messages take
> up every time I swapon.  I can see that you're following a page_cgroup
> precedent, one which never bothered me because it got buried in dmesg;
> and most other people wouldn't be doing swapon very often, and wouldn't
> be logging to a visible screen ... but is there any chance of putting an
> approximation to this info in the CGROUP_MEM_RES_CTRL_SWAP Kconfig help
> text and removing these runtime messages?  How do other people feel?
>

We could just print out the numbers and point to the Documentation for
the user to look at.
 
> I'm also disappointed that we invented such a tortuously generic boot
> option as "cgroup_disable=memory", then departed from it when the very
> first extension "noswapaccount" was required.  "cgroup_disable=swap"?
> Probably too late.
>

Good suggestion and it makes things more consistent for the end user.
It might be too early to start obsoleting noswapaccount?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
