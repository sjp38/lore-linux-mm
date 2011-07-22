Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B8E9C6B00EC
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:26:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8919C3EE0B6
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:26:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 458BD2E68C4
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:26:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D1BC2E68CA
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:26:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90BD61DB803C
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:26:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A9B41DB8040
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:26:06 +0900 (JST)
Date: Fri, 22 Jul 2011 09:18:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] memcg: prevent from reclaiming if there are per-cpu
 cached charges
Message-Id: <20110722091858.f4b78e14.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110722085652.759aded2.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1311241300.git.mhocko@suse.cz>
	<0ed59a22cc84037d6e42b258981c75e3a6063899.1311241300.git.mhocko@suse.cz>
	<20110721195411.f4fa9f91.kamezawa.hiroyu@jp.fujitsu.com>
	<20110721123012.GD27855@tiehlicka.suse.cz>
	<20110722085652.759aded2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org

On Fri, 22 Jul 2011 08:56:52 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 21 Jul 2011 14:30:12 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
 
> Please wait until "background reclaim" stuff. I don't stop it and it will
> make this cpu-caching stuff better because we can drain before hitting
> limit.
> 
> If you cannot wait....
> 
> One idea is to have a threshold to call async "drain". For example,
> 
>  threshould = limit_of_memory - nr_online_cpu() * (BATCH_SIZE + 1)
> 
>  if (usage > threshould)
> 	drain_all_stock_async().
> 
> Then, situation will be much better.
> 

Of course, frequency of this call can be controlled by event counter.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
