Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB53ocdZ029372
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Dec 2008 12:50:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 41BBC45DD7A
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:50:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 205EC45DD77
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:50:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 06F331DB8037
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:50:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BD8C1DB803C
	for <linux-mm@kvack.org>; Fri,  5 Dec 2008 12:50:37 +0900 (JST)
Date: Fri, 5 Dec 2008 12:49:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG ?] failed to boot on IA64 with CONFIG_DISCONTIGMEM=y
Message-Id: <20081205124947.0450a222.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4938A088.1090205@cn.fujitsu.com>
References: <49389B69.9010902@cn.fujitsu.com>
	<20081205122024.3fcc1d0e.kamezawa.hiroyu@jp.fujitsu.com>
	<20081205122458.a37ae8e0.kamezawa.hiroyu@jp.fujitsu.com>
	<4938A088.1090205@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 05 Dec 2008 11:31:20 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> >> How about this ?
> > 
> > Ahhh..sorry.
> > 
> > this one please.
> > ==
> > 
> > From: kamezawa.hiroyu@jp.fujitsu.com
> > 
> > page_cgroup should ignore empty-nodes.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> Now it booted successfully. :)
> 
> Tested-by: Li Zefan <lizf@cn.fujitsu.com>
> 
Thank you!

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
