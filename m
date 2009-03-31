Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBD86B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 01:02:17 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp07.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2V5291S022565
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 16:02:09 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2V527Sf438670
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 16:02:09 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2V527XE008496
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 16:02:07 +1100
Date: Tue, 31 Mar 2009 10:31:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-ID: <20090331050143.GG16497@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com> <20090328181100.GB26686@balbir.in.ibm.com> <20090328182747.GA8339@balbir.in.ibm.com> <20090331090607.7ebc44c5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090331090607.7ebc44c5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-31 09:06:07]:

> On Sat, 28 Mar 2009 23:57:47 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-03-28 23:41:00]:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 13:59:33]:
> > > 
> > > > ==brief test result==
> > > > On 2CPU/1.6GB bytes machine. create group A and B
> > > >   A.  soft limit=300M
> > > >   B.  no soft limit
> > > > 
> > > >   Run a malloc() program on B and allcoate 1G of memory. The program just
> > > >   sleeps after allocating memory and no memory refernce after it.
> > > >   Run make -j 6 and compile the kernel.
> > > > 
> > > >   When vm.swappiness = 60  => 60MB of memory are swapped out from B.
> > > >   When vm.swappiness = 10  => 1MB of memory are swapped out from B    
> > > > 
> > > >   If no soft limit, 350MB of swap out will happen from B.(swapiness=60)
> > > >
> > > 
> > > I ran the same tests, booted the machine with mem=1700M and maxcpus=2
> > > 
> > > Here is what I see with
> > 
> > I meant to say, Here is what I see with my patches (v7)
> > 
> 
> your malloc program is like this ?
> 
> int main(int argc, char *argv[])
> {
>     c = malloc(1G);
>     memset(c, 0, 1G);
>     getc();
> }
>

Very similar, instead of memset, we go integer by integer and set it
to 0, do two loops of touching and wait for user input before exiting.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
