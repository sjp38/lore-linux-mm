Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B13905F0048
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 00:31:49 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K4Vkcj016594
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Oct 2010 13:31:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C395245DE53
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:31:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B05A45DE4F
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:31:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CAA91DB803F
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:31:46 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 334211DB8038
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 13:31:46 +0900 (JST)
Date: Wed, 20 Oct 2010 13:26:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 02/11] memcg: document cgroup dirty memory interfaces
Message-Id: <20101020132619.5867d71d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93vd4xze0e.fsf@ninji.mtv.corp.google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-3-git-send-email-gthelen@google.com>
	<20101019172744.45e0a8dc.nishimura@mxp.nes.nec.co.jp>
	<xr93lj5t5245.fsf@ninji.mtv.corp.google.com>
	<20101020091109.ccd7b39a.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93r5fl1poc.fsf@ninji.mtv.corp.google.com>
	<20101020130654.bf861eda.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93vd4xze0e.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010 21:25:53 -0700
Greg Thelen <gthelen@google.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > On Tue, 19 Oct 2010 17:45:08 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> >> > BTW, how about supporing dirty_limit_in_bytes when use_hierarchy=0 or
> >> > leave it as broken when use_hierarchy=1 ?  It seems we can only
> >> > support dirty_ratio when hierarchy is used.
> >> 
> >> I am not sure what you mean here.
> >
> > When using dirty_ratio, we can check the value of dirty_ratio at setting it
> > and make guarantee that any children's dirty_ratio cannot exceeds it parent's.
> >
> > If we guarantee that, we can keep dirty_ratio even under hierarchy.
> >
> > When it comes to dirty_limit_in_bytes, we never able to do such kind of
> > controls. So, it will be broken and will do different behavior than
> > dirty_ratio.
> 
> I think that for use_hierarchy=1, we could support either dirty_ratio or
> dirty_limit_in_bytes.  The code that modifies dirty_limit_in_bytes could
> ensure that the sum the dirty_limit_in_bytes of each child does not
> exceed the parent's dirty_limit_in_bytes.
> 
But the sum of all children's dirty_bytes can exceeds. (Adding check code
will be messy at this stage. Maybe in TODO list)

> > So, not supporing dirty_bytes when use_hierarchy==1 for now sounds
> > reasonable to me.
> 
> Ok, I will add the use_hierarchy==1 check and repost the patches.
> 
> I will wait to post the -v4 patch series until you post an improved
> "[PATCH][memcg+dirtylimit] Fix overwriting global vm dirty limit setting
> by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page accounting"
> patch.  I think it makes sense to integrate that into -v4 of the series.
> 

yes...but I'm now wondering how "FreePages" of memcg should be handled...

Considering only dirtyable pages may make sense but it's different behavior
than global's one and the user will see the limitation of effects even when
they use only small pages. I'd like to consider this, too.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
