Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2CDA16B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 23:23:40 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o973Nbgc019263
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 12:23:37 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1458445DE56
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 12:23:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 854A045DE51
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 12:23:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DEE41DB805A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 12:23:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B2AA31DB804E
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 12:23:33 +0900 (JST)
Date: Thu, 7 Oct 2010 12:18:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-Id: <20101007121816.bbd009c1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101007031203.GK4195@balbir.in.ibm.com>
References: <20101006142314.GG4195@balbir.in.ibm.com>
	<20101007085858.0e07de59.kamezawa.hiroyu@jp.fujitsu.com>
	<20101007031203.GK4195@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Oct 2010 08:42:04 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-10-07 08:58:58]:
> 
> > On Wed, 6 Oct 2010 19:53:14 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > I propose restricting page_cgroup.flags to 16 bits. The patch for the
> > > same is below. Comments?
> > > 
> > > 
> > > Restrict the bits usage in page_cgroup.flags
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > Restricting the flags helps control growth of the flags unbound.
> > > Restriciting it to 16 bits gives us the possibility of merging
> > > cgroup id with flags (atomicity permitting) and saving a whole
> > > long word in page_cgroup
> > > 
> > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Doesn't make sense until you show the usage of existing bits.
> 
> ??
> 
Limiting something for NOT EXISTING PATCH doesn't make sense, in general.


> > And I guess 16bit may be too large on 32bit systems.
> 
> too large on 32 bit systems? My intention is to keep the flags to 16
> bits and then use cgroup id for the rest and see if we can remove
> mem_cgroup pointer
> 

You can't use flags field to store mem_cgroup_id while we use lock bit on it.
We have to store something more stable...as pfn or node-id or zone-id.

It's very racy. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
