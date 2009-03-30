Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EA5DF6B0047
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:56:14 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2UNv6m1025911
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 08:57:06 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D786745DE4F
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:57:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BADF445DE4E
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:57:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A33711DB803A
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:57:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B84A1DB8037
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:57:05 +0900 (JST)
Date: Tue, 31 Mar 2009 08:55:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090331085538.2aaa5e2b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090328182747.GA8339@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328181100.GB26686@balbir.in.ibm.com>
	<20090328182747.GA8339@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Mar 2009 23:57:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-03-28 23:41:00]:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 13:59:33]:
> > 
> > > ==brief test result==
> > > On 2CPU/1.6GB bytes machine. create group A and B
> > >   A.  soft limit=300M
> > >   B.  no soft limit
> > > 
> > >   Run a malloc() program on B and allcoate 1G of memory. The program just
> > >   sleeps after allocating memory and no memory refernce after it.
> > >   Run make -j 6 and compile the kernel.
> > > 
> > >   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
> > >   When vm.swappiness = 10  => 1MB of memory are swapped out from B    
> > > 
> > >   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
> > >
> > 
> > I ran the same tests, booted the machine with mem=1700M and maxcpus=2
> > 
> > Here is what I see with
> 
> I meant to say, Here is what I see with my patches (v7)
> 
Hmm, I saw 250MB of swap out ;) As I reported before.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
