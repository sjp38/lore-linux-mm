Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 13A776B006A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 00:08:07 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o973pdAw008384
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 23:51:39 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o97485EA469200
	for <linux-mm@kvack.org>; Thu, 7 Oct 2010 00:08:05 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o974851f004321
	for <linux-mm@kvack.org>; Wed, 6 Oct 2010 22:08:05 -0600
Date: Thu, 7 Oct 2010 09:38:02 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-ID: <20101007040802.GO4195@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101006142314.GG4195@balbir.in.ibm.com>
 <20101007095458.a992969e.nishimura@mxp.nes.nec.co.jp>
 <20101007031459.GL4195@balbir.in.ibm.com>
 <20101007124706.c602649e.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101007124706.c602649e.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-10-07 12:47:06]:

> On Thu, 7 Oct 2010 08:44:59 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-10-07 09:54:58]:
> > 
> > > On Wed, 6 Oct 2010 19:53:14 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > I propose restricting page_cgroup.flags to 16 bits. The patch for the
> > > > same is below. Comments?
> > > > 
> > > > 
> > > > Restrict the bits usage in page_cgroup.flags
> > > > 
> > > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > > 
> > > > Restricting the flags helps control growth of the flags unbound.
> > > > Restriciting it to 16 bits gives us the possibility of merging
> > > > cgroup id with flags (atomicity permitting) and saving a whole
> > > > long word in page_cgroup
> > > > 
> > > I agree that reducing the size of page_cgroup would be good and important.
> > > But, wouldn't it be better to remove ->page, if possible ?
> > >
> > 
> > Without the page pointer, how do we go from pc to page for reclaim? 
> > 
> We store page_cgroups in arrays now, so I suppose we can implement pc_to_pfn()
> using the similar calculation as page_to_pfn() does.
> IIRC, KAMEZAWA-san talked about it in another thread.
>

Yes, correct we do. Your suggestions, IIUC is to reuse part of the
flags to store the section number where the pc belongs and then use
that to remove ->page pointer.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
