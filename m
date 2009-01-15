Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CD22A6B0062
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 02:37:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F7b5al029379
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 16:37:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC7EA45DE61
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:37:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 97D9F45DE5D
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:37:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6404EE38002
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:37:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BAF26E18009
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:37:03 +0900 (JST)
Date: Thu, 15 Jan 2009 16:35:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
Message-Id: <20090115163559.ea5715c4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496EE683.8090101@cn.fujitsu.com>
References: <496ED2B7.5050902@cn.fujitsu.com>
	<20090115061557.GD30358@balbir.in.ibm.com>
	<20090115153134.632ebc85.kamezawa.hiroyu@jp.fujitsu.com>
	<496EE25E.3030703@cn.fujitsu.com>
	<20090115162126.cf040c63.kamezawa.hiroyu@jp.fujitsu.com>
	<496EE683.8090101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 15:32:19 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:

> > try_to_free_page() returns positive value if try_to_free_page() reclaims at
> > least 1 pages. It itself doesn't seem to be buggy.
> > 
> > What buggy is resize_limit's retry-out check code, I think.
> > 
> > How about following ?
> 
> Not sure.
> 
> I didn't look into the reclaim code, so I'd rather let you and Balbir decide if
> this is a bug and (if yes) how to fix it.
> 

Hmm, I personally think this is not a bug. But *UNEXPECTED* behavior change, yes,
it's called regression.

To be honest, I never like retry-by-count because there is no trustable logic.
Thank you for reporting anyway. I'll consider some workaround.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
