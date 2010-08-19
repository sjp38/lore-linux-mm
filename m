Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CA606B020A
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:14:27 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7JF0cOY003309
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:00:38 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7JFELw4123742
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:14:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7JFEK7p024825
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:14:20 -0400
Date: Thu, 19 Aug 2010 20:43:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Over-eager swapping
Message-ID: <20100819151351.GA23611@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100819051339.GH28417@balbir.in.ibm.com>
 <20100818164539.GG28417@balbir.in.ibm.com>
 <20100819092536.GH2370@arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100819092536.GH2370@arachsys.com>
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Chris Webb <chris@arachsys.com> [2010-08-19 10:25:36]:

> Balbir Singh <balbir@linux.vnet.ibm.com> writes:
> 
> > Can you give an idea of what the meminfo inside the guest looks like.
> 
> Sorry for the slow reply here. Unfortunately not, as these guests are run on
> behalf of customers. They install them with operating systems of their
> choice, and run them on our service.
>

Thanks for clarifying.
 
> > Have you looked at
> > http://kerneltrap.org/mailarchive/linux-kernel/2010/6/8/4580772
> 
> Yes, I've been watching this discussions with interest. Our application is
> one where we have little to no control over what goes on inside the guests,
> but these sorts of things definitely make sense where the two are under the
> same administrative control.
>

Not necessarily, in some cases you can use a guest that uses lesser
page cache, but that might not matter in your case at the moment.
 
> > Do we have reason to believe the problem can be solved entirely in the
> > host?
> 
> It's not clear to me why this should be difficult, given that the total size
> of vm allocated to guests (and system processes) is always strictly less
> than the total amount of RAM available in the host. I do understand that it
> won't allow for as impressive overcommit (except by ksm) or be as efficient,
> because file-backed guest pages won't get evicted by pressure in the host as
> they are indistinguishable from anonymous pages.
>
> After all, a solution that isn't ideal, but does work, is to turn off swap
> completely! This is what we've been doing to date. The only problem with
> this is that we can't dip into swap in an emergency if there's no swap there
> at all.

If you are not overcommitting it should work, in my experiments I've
seen a lot of memory used by the host as page cache on behalf of the
guest. I've done my experiments using cgroups to identify accurate
usage.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
