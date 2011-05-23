Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 70DE56B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 20:15:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5F0D93EE0C2
	for <linux-mm@kvack.org>; Mon, 23 May 2011 09:15:20 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3868545DE97
	for <linux-mm@kvack.org>; Mon, 23 May 2011 09:15:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 202C445DE92
	for <linux-mm@kvack.org>; Mon, 23 May 2011 09:15:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 106CB1DB8037
	for <linux-mm@kvack.org>; Mon, 23 May 2011 09:15:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CAA1EE08002
	for <linux-mm@kvack.org>; Mon, 23 May 2011 09:15:19 +0900 (JST)
Date: Mon, 23 May 2011 09:08:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V5] memcg: add memory.numastat api for numa statistics
Message-Id: <20110523090816.3ab157d4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1305928918-15207-1-git-send-email-yinghan@google.com>
References: <1305928918-15207-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, 20 May 2011 15:01:58 -0700
Ying Han <yinghan@google.com> wrote:

> The new API exports numa_maps per-memcg basis. This is a piece of useful
> information where it exports per-memcg page distribution across real numa
> nodes.
> 
> One of the usecase is evaluating application performance by combining this
> information w/ the cpu allocation to the application.
> 
> The output of the memory.numastat tries to follow w/ simiar format of numa_maps
> like:
> 
> total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> 

Ah, please update Documentaion please.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
