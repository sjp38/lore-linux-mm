Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DCFDF6B004F
	for <linux-mm@kvack.org>; Mon, 11 May 2009 20:45:48 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4C0kTJM030029
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 May 2009 09:46:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FECA45DE55
	for <linux-mm@kvack.org>; Tue, 12 May 2009 09:46:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 28F1045DE53
	for <linux-mm@kvack.org>; Tue, 12 May 2009 09:46:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 047DD1DB8037
	for <linux-mm@kvack.org>; Tue, 12 May 2009 09:46:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD35B1DB803B
	for <linux-mm@kvack.org>; Tue, 12 May 2009 09:46:28 +0900 (JST)
Date: Tue, 12 May 2009 09:44:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg fix stale swap cache account leak v6
Message-Id: <20090512094459.79b59cee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090511122711.GF13954@elte.hu>
References: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com>
	<20090508140910.bb07f5c6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090508113820.GL11596@elte.hu>
	<a369eb83999c47faac2bc894c2f43a9d.squirrel@webmail-b.css.fujitsu.com>
	<20090511122711.GF13954@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 May 2009 14:27:11 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > Isnt the right solution to have a better LRU that is aware of 
> > > this, instead of polling around in the hope of cleaning up stale 
> > > entries?
> >
> > I tried to modify LRU in the last month but I found it's 
> > difficult.
> 
> But your patch makes such a correct solution even more difficult to 
> achieve, so in that sense it might be a step backwards, right?
> 
Hmm...maybe or not. This leak comes from laziness of LRU and trylock() swap handling
for avoiding contentions. So, even if we addd new LRU, we need some trick to do
synchronous work.

Anyway, I'll use Nishimura's one, which is simple.
This is a bug fix and I don't want a patch which needs a half year testing ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
