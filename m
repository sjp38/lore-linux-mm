Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C3AA86B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 02:05:25 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 64C643EE0C3
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:05:22 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B67045DE9A
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:05:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 27A4345DE95
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:05:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 198841DB802F
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:05:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8A271DB8040
	for <linux-mm@kvack.org>; Mon, 16 May 2011 15:05:21 +0900 (JST)
Date: Mon, 16 May 2011 14:58:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v7 10/14] memcg: dirty page accounting support
 routines
Message-Id: <20110516145811.405a6790.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTin6_CiP-Q8MyN=PKhpUhGhdmUQyEA@mail.gmail.com>
References: <1305276473-14780-1-git-send-email-gthelen@google.com>
	<1305276473-14780-11-git-send-email-gthelen@google.com>
	<20110513185612.84b466ec.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin6_CiP-Q8MyN=PKhpUhGhdmUQyEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>

On Sun, 15 May 2011 12:56:00 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Fri, May 13, 2011 at 2:56 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 13 May 2011 01:47:49 -0700
> > Greg Thelen <gthelen@google.com> wrote:

> >> +static unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  enum mem_cgroup_page_stat_item item)
> >
> > How about mem_cgroup_file_cache_stat() ?
> 
> The suggested rename is possible.  But for consistency I assume we
> would also want to rename:
> * mem_cgroup_local_page_stat()
> * enum mem_cgroup_page_stat_item
> * mem_cgroup_update_page_stat()
> * mem_cgroup_move_account_page_stat()
> 

Yes, maybe clean up is necessary.

> I have a slight preference for leaving it as is,
> mem_cgroup_page_stat(), to allow for future coverage of pages other
> that just file cache pages.  But I do not feel very strongly.
> 

ok, I'm not have big concern on naming for now. please do as you like.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
