Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B51076B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 02:58:47 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9276xfm000732
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Oct 2009 16:07:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CB99145DE6E
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 16:06:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB57145DE4D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 16:06:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9090E1DB8037
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 16:06:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26B291DB8040
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 16:06:56 +0900 (JST)
Date: Fri, 2 Oct 2009 16:04:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: coalescing uncharge at unmap and truncation
Message-Id: <20091002160437.4871306f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4AC5A35F.3040308@ct.jp.nec.com>
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
	<20091002140126.61d15e5e.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC5A1FA.1080208@ct.jp.nec.com>
	<4AC5A35F.3040308@ct.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nis@tyo205.gate.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 02 Oct 2009 15:53:19 +0900
Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com> wrote:

> Hiroshi Shimamoto wrote:
> > KAMEZAWA Hiroyuki wrote:

> >> +static inline void mem_cgroup_uncharge_batch_start(void)
> >> +{
> >> +}
> >> +
> >> +static inline void mem_cgroup_uncharge_batch_start(void)
> > 
> > mem_cgroup_uncharge_batch_end?
> 
> s/_batch// too?
> 
thank you. fixed.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
