Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 17BFE6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 23:12:12 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9734JEV032548
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 21:04:19 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o973C8vJ175090
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 21:12:09 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o973C8pL026188
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 21:12:08 -0600
Date: Thu, 7 Oct 2010 08:42:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-ID: <20101007031203.GK4195@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101006142314.GG4195@balbir.in.ibm.com>
 <20101007085858.0e07de59.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101007085858.0e07de59.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: containers@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-07 08:58:58]:

> On Wed, 6 Oct 2010 19:53:14 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > I propose restricting page_cgroup.flags to 16 bits. The patch for the
> > same is below. Comments?
> > 
> > 
> > Restrict the bits usage in page_cgroup.flags
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Restricting the flags helps control growth of the flags unbound.
> > Restriciting it to 16 bits gives us the possibility of merging
> > cgroup id with flags (atomicity permitting) and saving a whole
> > long word in page_cgroup
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Doesn't make sense until you show the usage of existing bits.

??

> And I guess 16bit may be too large on 32bit systems.

too large on 32 bit systems? My intention is to keep the flags to 16
bits and then use cgroup id for the rest and see if we can remove
mem_cgroup pointer

> Nack for now.
>

The issue is - do you see further growth of flags?
 
> Thanks,
> -Kame
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
