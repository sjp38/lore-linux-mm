Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 896F56B004D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 00:03:27 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C43OPx010442
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 13:03:24 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D3A6145DD77
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:03:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AF9E545DD75
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:03:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 95ED21DB801B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:03:23 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 470DBE18002
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:03:23 +0900 (JST)
Date: Thu, 12 Mar 2009 13:02:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/5] memcg softlimit hooks to kswapd
Message-Id: <20090312130200.5c0e19d1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312035837.GD23583@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312100008.aa8379d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312035837.GD23583@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:28:37 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 10:00:08]:

> > +	return;
> > +}
> 
> I experimented a *lot* with zone reclaim and found it to be not so
> effective. Here is why
> 
> 1. We have no control over priority or how much to scan, that is
> controlled by balance_pgdat(). If we find that we are unable to scan
> anything, we continue scanning with the scan > 0 check, but we scan
> the same pages and the same number, because shrink_zone does scan >>
> priority.

If sc->nr_reclaimd==0, "false" is passed and mem_cgroup_schedule_end()
and it will be moved to INACTIVE queue. (and not appear here again.)


> 2. If we fail to reclaim pages in shrink_zone_softlimit, shrink_zone()
> will reclaim pages independent of the soft limit for us
> 
yes. It's intentional behavior.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
