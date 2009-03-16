Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 23C616B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 18:25:31 -0400 (EDT)
Date: Mon, 16 Mar 2009 22:25:13 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] use css id in swap cgroup for saving memory v5
In-Reply-To: <20090312084623.e98d80b9.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0903162217030.3560@blonde.anvils>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
 <20090310160856.77deb5c3.akpm@linux-foundation.org>
 <20090311085326.403a211d.kamezawa.hiroyu@jp.fujitsu.com>
 <isapiwc.d14e3c29.6b18.49b7092b.9bc73.52@mail.jp.nec.com>
 <20090311094739.3123b05d.kamezawa.hiroyu@jp.fujitsu.com>
 <20090311120427.2467bd14.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0903111041260.16964@blonde.anvils>
 <20090312084623.e98d80b9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009, KAMEZAWA Hiroyuki wrote:
> On Wed, 11 Mar 2009 11:05:55 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> > > @@ -432,7 +428,7 @@ int swap_cgroup_swapon(int type, unsigne
> > >  
> > >  	printk(KERN_INFO
> > >  		"swap_cgroup: uses %ld bytes of vmalloc for pointer array space"
> > > -		" and %ld bytes to hold mem_cgroup pointers on swap\n",
> > > +		" and %ld bytes to hold mem_cgroup information per swap ents\n",
> > >  		array_size, length * PAGE_SIZE);
> > >  	printk(KERN_INFO
> > >  	"swap_cgroup can be disabled by noswapaccount boot option.\n");
> > 
> > ... I do get very irritated by all the screenspace these messages take
> > up every time I swapon.  I can see that you're following a page_cgroup
> > precedent, one which never bothered me because it got buried in dmesg;
> > and most other people wouldn't be doing swapon very often, and wouldn't
> > be logging to a visible screen ... but is there any chance of putting an
> > approximation to this info in the CGROUP_MEM_RES_CTRL_SWAP Kconfig help
> > text and removing these runtime messages?  How do other people feel?
> > 
> Ok, will remove this. (in other patch.)

Thanks!

> 
> > I'm also disappointed that we invented such a tortuously generic boot
> > option as "cgroup_disable=memory", then departed from it when the very
> > first extension "noswapaccount" was required.  "cgroup_disable=swap"?
> > Probably too late.
> > 
> Hmm, cgroup_disable=memory is option to disable memory cgroup and "memory"
> is the subsytem name of cgroup. But "swap" isn't.

Yes, "swap" was always going to be a more awkward case than a cgroup.

> Just removing "noswapaccount" option is ok ? Anyway, there is config.

Removing "noswapaccount" would be okay by me, but I don't think you
should remove it without wider agreement of mem_cgroup folks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
