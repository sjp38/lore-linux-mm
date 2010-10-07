Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D1DDA6B006A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 23:49:10 -0400 (EDT)
Date: Thu, 7 Oct 2010 12:47:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-Id: <20101007124706.c602649e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101007031459.GL4195@balbir.in.ibm.com>
References: <20101006142314.GG4195@balbir.in.ibm.com>
	<20101007095458.a992969e.nishimura@mxp.nes.nec.co.jp>
	<20101007031459.GL4195@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, containers@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Oct 2010 08:44:59 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-10-07 09:54:58]:
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
> > I agree that reducing the size of page_cgroup would be good and important.
> > But, wouldn't it be better to remove ->page, if possible ?
> >
> 
> Without the page pointer, how do we go from pc to page for reclaim? 
> 
We store page_cgroups in arrays now, so I suppose we can implement pc_to_pfn()
using the similar calculation as page_to_pfn() does.
IIRC, KAMEZAWA-san talked about it in another thread.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
