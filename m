Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 04B946B00A9
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 01:19:32 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N6ITsO007536
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 15:18:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B031F45DE51
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:18:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8636545DE54
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:18:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 689221DB8016
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:18:29 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 14BD81DB8012
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:18:29 +0900 (JST)
Date: Mon, 23 Mar 2009 15:17:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323052247.GJ24227@balbir.in.ibm.com>
	<20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 15:12:45 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 23 Mar 2009 10:52:47 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > I have one large swap partition, so I could not test the partial-swap
> > scenario.
> > 
> plz go ahead as you like, Seems no landing point now and I'd like to see
> what I can, later. I'll send no ACK nor NACK, more.
> 
But I dislike the whole concept, at all.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
