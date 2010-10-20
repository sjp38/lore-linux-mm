Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0765F004B
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:49:15 -0400 (EDT)
Date: Wed, 20 Oct 2010 12:47:14 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v3 02/11] memcg: document cgroup dirty memory interfaces
Message-Id: <20101020124714.4bef3479.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101020112431.b76b861d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-3-git-send-email-gthelen@google.com>
	<20101019172744.45e0a8dc.nishimura@mxp.nes.nec.co.jp>
	<xr93lj5t5245.fsf@ninji.mtv.corp.google.com>
	<20101020091109.ccd7b39a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020094821.75c70fe3.nishimura@mxp.nes.nec.co.jp>
	<20101020101421.05325710.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020112431.b76b861d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010 11:24:31 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 20 Oct 2010 10:14:21 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 20 Oct 2010 09:48:21 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Wed, 20 Oct 2010 09:11:09 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Tue, 19 Oct 2010 14:00:58 -0700
> > > > Greg Thelen <gthelen@google.com> wrote:
> > > > 
> > > (snip)
> > > > > +When use_hierarchy=0, each cgroup has independent dirty memory usage and limits.
> > > > > +
> > > > > +When use_hierarchy=1, a parent cgroup increasing its dirty memory usage will
> > > > > +compare its total_dirty memory (which includes sum of all child cgroup dirty
> > > > > +memory) to its dirty limits.  This keeps a parent from explicitly exceeding its
> > > > > +dirty limits.  However, a child cgroup can increase its dirty usage without
> > > > > +considering the parent's dirty limits.  Thus the parent's total_dirty can exceed
> > > > > +the parent's dirty limits as a child dirties pages.
> > > > 
> > > > Hmm. in short, dirty_ratio in use_hierarchy=1 doesn't work as an user expects.
> > > > Is this a spec. or a current implementation ?
> > > > 
> > > > I think as following.
> > > >  - add a limitation as "At setting chidlren's dirty_ratio, it must be below parent's.
> > > >    If it exceeds parent's dirty_ratio, EINVAL is returned."
> > > > 
> > > > Could you modify setting memory.dirty_ratio code ?
> > > > Then, parent's dirty_ratio will never exceeds its own. (If I understand correctly.)
> > > > 
> > > > "memory.dirty_limit_in_bytes" will be a bit more complecated, but I think you can.
> > > > 
> > > I agree.
> > > 
> > > At the first impression, this limitation seems a bit overkill for me, because
> > > we allow memory.limit_in_bytes of a child bigger than that of parent now.
> > > But considering more, the situation is different, because usage_in_bytes never
> > > exceeds limit_in_bytes.
> > > 
> > 
> > I'd like to consider a patch.
> > Please mention that "use_hierarchy=1 case depends on implemenation." for now.
> > 
> 
> BTW, how about supporing dirty_limit_in_bytes when use_hierarchy=0 or leave it as
> broken when use_hierarchy=1 ?
> It seems we can only support dirty_ratio when hierarchy is used.
> 
It's all right for me.
This feature would be useful even w/o hierarchy support.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
