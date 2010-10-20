Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3408B5F0048
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 00:26:10 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 02/11] memcg: document cgroup dirty memory interfaces
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-3-git-send-email-gthelen@google.com>
	<20101019172744.45e0a8dc.nishimura@mxp.nes.nec.co.jp>
	<xr93lj5t5245.fsf@ninji.mtv.corp.google.com>
	<20101020091109.ccd7b39a.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93r5fl1poc.fsf@ninji.mtv.corp.google.com>
	<20101020130654.bf861eda.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 19 Oct 2010 21:25:53 -0700
Message-ID: <xr93vd4xze0e.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Tue, 19 Oct 2010 17:45:08 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
>> > BTW, how about supporing dirty_limit_in_bytes when use_hierarchy=0 or
>> > leave it as broken when use_hierarchy=1 ?  It seems we can only
>> > support dirty_ratio when hierarchy is used.
>> 
>> I am not sure what you mean here.
>
> When using dirty_ratio, we can check the value of dirty_ratio at setting it
> and make guarantee that any children's dirty_ratio cannot exceeds it parent's.
>
> If we guarantee that, we can keep dirty_ratio even under hierarchy.
>
> When it comes to dirty_limit_in_bytes, we never able to do such kind of
> controls. So, it will be broken and will do different behavior than
> dirty_ratio.

I think that for use_hierarchy=1, we could support either dirty_ratio or
dirty_limit_in_bytes.  The code that modifies dirty_limit_in_bytes could
ensure that the sum the dirty_limit_in_bytes of each child does not
exceed the parent's dirty_limit_in_bytes.

> So, not supporing dirty_bytes when use_hierarchy==1 for now sounds
> reasonable to me.

Ok, I will add the use_hierarchy==1 check and repost the patches.

I will wait to post the -v4 patch series until you post an improved
"[PATCH][memcg+dirtylimit] Fix overwriting global vm dirty limit setting
by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page accounting"
patch.  I think it makes sense to integrate that into -v4 of the series.

> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
