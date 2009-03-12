Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 162476B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 00:41:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C4fBro032431
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 13:41:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8912B45DE62
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:41:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57C5245DD79
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:41:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 071F5E1800A
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:41:11 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A533EE38005
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:41:10 +0900 (JST)
Date: Thu, 12 Mar 2009 13:39:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-Id: <20090312133949.130b20ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312034647.GA23583@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312034647.GA23583@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:16:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:52:47]:
> I've tested so far by
> 
> Creating two cgroups and then 
> 
> a. Assigning limits of 1G and 2G and run memory allocation and touch
> test
softlimit ?

> b. Same as (a) with 1G and 1G
> c. Same as (a) with 0 and 1G
> d. Same as (a) with 0 and 0
> 
> More comments in induvidual patches.
> 
Then,
  1. what's the number of active threads ?
  2. what's the number of cpus ?
  3. what's the numa configuration, if numa ?
  4. what's the zone configuration ?
  5. what's arch ?
  6. what's amount of total memory ?
  7. Do you find difference in behavior with and without softlimit ?
  8. Do you tested *this* version ?

Thanks,
-Kame


> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
