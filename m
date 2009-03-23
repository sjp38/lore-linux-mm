Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 722D16B00BB
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:47:51 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N8n9Le005754
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 17:49:09 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1090945DE4F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:49:09 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E60B745DD72
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:49:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E70751DB8040
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:49:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 817401DB804E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 17:49:08 +0900 (JST)
Date: Mon, 23 Mar 2009 17:47:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090323174743.87959966.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323082244.GK24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
	<20090320124639.83d22726.kamezawa.hiroyu@jp.fujitsu.com>
	<20090322142105.GA24227@balbir.in.ibm.com>
	<20090323085314.7cce6c50.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323033404.GG24227@balbir.in.ibm.com>
	<20090323123841.caa91874.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323041559.GI24227@balbir.in.ibm.com>
	<20090323132308.941b617d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323082244.GK24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 13:52:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> I don't see why you are harping about something that you might think
> is a problem and want to over-optimize even without tests. Fix
> something when you can see the problem, on my system I don't see it. I
> am willing to consider alternatives or moving away from the current
> coding style *iff* it needs to be redone for better performance.
> 

It's usually true that "For optimize system, don't do anything unnecessary".
And the patch increase size of res_counter_charge from 236bytes to 295bytes.
on my compliler.

And this is called at every charge if the check is unnecessary.
(i.e. the _real_ check itself is done once in a HZ/?)

Thanks
-Kame


> What I am proposing is that we do iterative development, get the
> functionality right and then if needed tune for performance.
> 
> 
> 
> -- 
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
