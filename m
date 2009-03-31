Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 217456B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 01:13:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V5DDZc004314
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 14:13:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A88F745DD79
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:13:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FAAE45DE61
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:13:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EFD61DB8042
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:13:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 42A2B1DB803B
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 14:13:08 +0900 (JST)
Date: Tue, 31 Mar 2009 14:11:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090331141140.9acd9b85.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090331050143.GG16497@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328181100.GB26686@balbir.in.ibm.com>
	<20090328182747.GA8339@balbir.in.ibm.com>
	<20090331090607.7ebc44c5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331050143.GG16497@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 10:31:43 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 09:06:07]:
> 
> > On Sat, 28 Mar 2009 23:57:47 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-03-28 23:41:00]:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 13:59:33]:
> > > > 
> > > > > ==brief test result==
> > > > > On 2CPU/1.6GB bytes machine. create group A and B
> > > > >   A.  soft limit=300M
> > > > >   B.  no soft limit
> > > > > 
> > > > >   Run a malloc() program on B and allcoate 1G of memory. The program just
> > > > >   sleeps after allocating memory and no memory refernce after it.
> > > > >   Run make -j 6 and compile the kernel.
> > > > > 
> > > > >   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
> > > > >   When vm.swappiness = 10  => 1MB of memory are swapped out from B    
> > > > > 
> > > > >   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
> > > > >
> > > > 
> > > > I ran the same tests, booted the machine with mem=1700M and maxcpus=2
> > > > 
> > > > Here is what I see with
> > > 
> > > I meant to say, Here is what I see with my patches (v7)
> > > 
> > 
> > your malloc program is like this ?
> > 
> > int main(int argc, char *argv[])
> > {
> >     c = malloc(1G);
> >     memset(c, 0, 1G);
> >     getc();
> > }
> >
> 
> Very similar, instead of memset, we go integer by integer and set it
> to 0, do two loops of touching and wait for user input before exiting.
>  
Why two loops of touching ? has special meanings ?

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
