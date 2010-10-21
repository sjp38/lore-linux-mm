Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AAB896B0088
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 20:15:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9L0FvaM009762
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 Oct 2010 09:15:57 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D831745DE51
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:15:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BA88F45DE4E
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:15:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A21BB1DB8040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:15:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CF081DB8038
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 09:15:56 +0900 (JST)
Date: Thu, 21 Oct 2010 09:10:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2][memcg+dirtylimit] Fix  overwriting global vm dirty
 limit setting by memcg (Re: [PATCH v3 00/11] memcg: per cgroup dirty page
 accounting
Message-Id: <20101021091029.48082934.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101020143515.GB5243@barrios-desktop>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<20101020122144.47f2b60b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020140255.5b8afb63.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020143515.GB5243@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010 23:35:15 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Oct 20, 2010 at 02:02:55PM +0900, KAMEZAWA Hiroyuki wrote:
> > Fixed one here.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, at calculating dirty limit, vm_dirty_param() is called.
> > This function returns dirty-limit related parameters considering
> > memory cgroup settings.
> > 
> > Now, assume that vm_dirty_bytes=100M (global dirty limit) and
> > memory cgroup has 1G of pages and 40 dirty_ratio, dirtyable memory is
> > 500MB.
> > 
> > In this case, global_dirty_limits will consider dirty_limt as
> > 500 *0.4 = 200MB. This is bad...memory cgroup is not back door.
> > 
> > This patch limits the return value of vm_dirty_param() considring
> > global settings.
> > 
> > Changelog:
> >  - fixed an argument "mem" int to u64
> >  - fixed to use global available memory to cap memcg's value.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> It should have written this on Documentation.
> "memcg dirty limit can't exceed global dirty limit"
> 
Sure. Anyway we need review & rewrite Documenation after dirty limit
merged. (I think Greg will do much.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
