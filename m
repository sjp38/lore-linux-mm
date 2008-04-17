Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3HNGKJZ030125
	for <linux-mm@kvack.org>; Thu, 17 Apr 2008 19:16:20 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3HNGKio296636
	for <linux-mm@kvack.org>; Thu, 17 Apr 2008 19:16:20 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3HNGJpM027963
	for <linux-mm@kvack.org>; Thu, 17 Apr 2008 19:16:20 -0400
Date: Thu, 17 Apr 2008 16:16:17 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080417231617.GA18815@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080414210506.GA6350@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, clameter@sgi.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.04.2008 [14:05:06 -0700], Nishanth Aravamudan wrote:
> On 12.04.2008 [20:41:36 -0700], Greg KH wrote:
> > On Sat, Apr 12, 2008 at 11:41:18AM +0200, Nick Piggin wrote:
> > > On Fri, Apr 11, 2008 at 04:56:48PM -0700, Greg KH wrote:
> > > > On Fri, Apr 11, 2008 at 04:49:13PM -0700, Nishanth Aravamudan wrote:
> > > > > /sys/devices/system/node represents the current NUMA configuration of
> > > > > the machine, but is undocumented in the ABI files. Add bare-bones
> > > > > documentation for these files.
> > > > > 
> > > > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > > > 
> > > > > ---
> > > > > Greg, is something like this what you'd want?
> > > > 
> > > > Yes it is, thanks for doing it.
> > > 
> > > Can you comment on the aspect of configuring various kernel hugetlb 
> > > configuration parameters? Especifically, what directory it should go in?
> > > IMO it should be /sys/kernel/*
> > 
> > I don't really know.
> > 
> > > /sys/devices/system/etc should be fine eg. for showing how many pages are
> > > available in a given node, or what kinds of TLBs the CPU has, but I would
> > > have thought that configuring the kernel's hugetlb settings should be
> > > in /sys/kernel.
> > 
> > /sys/devices/system are for "sysdev" devices, a breed of device
> > structures that are problimatic to use, and are on my TODO list to
> > rework.  If you need a hugetlb paramter to be tied to a cpu or other
> > system device, then it should go under here.
> > 
> > Otherwise, if it is just a "system wide" parameter, then put it in
> > /sys/kernel/
> 
> We have both, and that's kind of where things are being discussed right
> now.

<snip>

> Do you see a particular more-sysfs-way here, Greg?

So I've received no comments yet? Perhaps I should leave things the way
they are (per-node files in /sys/devices/system/node) and add
nr_hugepages to /sys/kernel?

Do we want to put it in a subdirectory of /sys/kernel? What should the
subdir be called? "hugetlb" (refers to the implementation?) or
"hugepages"?

Do we want nr_hugepages in sysfs to actually be a symlink to the
underlying default hugepage size (in my patch, there will be only one,
but it allows for future-proofing)? Or I can make it a real file in my
patch and the multiple hugepage sizes at run-time patchset (which I'm
willing to help with) can change it to a symlink?

Thoughts?
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
