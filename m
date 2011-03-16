Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 64F928D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 20:07:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 759C93EE0C5
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:07:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DC0F45DE68
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:07:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4540945DE55
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:07:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 35CE41DB803F
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:07:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EB4D51DB8038
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:07:17 +0900 (JST)
Date: Wed, 16 Mar 2011 09:00:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 6/9] memcg: add cgroupfs interface to memcg dirty
 limits
Message-Id: <20110316090042.e1f0183b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4D7F7121.5040009@librato.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
	<1299869011-26152-7-git-send-email-gthelen@google.com>
	<4D7F7121.5040009@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Heffner <mike@librato.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Andrea Righi <arighi@develer.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>

On Tue, 15 Mar 2011 10:01:05 -0400
Mike Heffner <mike@librato.com> wrote:

> On 03/11/2011 01:43 PM, Greg Thelen wrote:
> > Add cgroupfs interface to memcg dirty page limits:
> >    Direct write-out is controlled with:
> >    - memory.dirty_ratio
> >    - memory.dirty_limit_in_bytes
> >
> >    Background write-out is controlled with:
> >    - memory.dirty_background_ratio
> >    - memory.dirty_background_limit_bytes
> 
> 
> What's the overlap, if any, with the current memory limits controlled by 
> `memory.limit_in_bytes` and the above `memory.dirty_limit_in_bytes`? If 
> I want to fairly balance memory between two cgroups be one a dirty page 
> antagonist (dd) and the other an anonymous page (memcache), do I just 
> set `memory.limit_in_bytes`? Does this patch simply provide a more 
> granular level of control of the dirty limits?
> 

dirty_ratio is for control
 - speed of write() within cgroup.
 - risk of huge latency at memory reclaim (and OOM)
   Small dirty ratio means big ratio of clean page within cgroup.
   This will make memory reclaim, pageout easier.

memory.limit_in_bytes controls the amount of memory.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
