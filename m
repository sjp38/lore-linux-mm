Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 35A6C6B007E
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 04:36:31 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ9aSli019155
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Nov 2009 18:36:28 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26AFD45DE60
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 18:36:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0357A45DE4D
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 18:36:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E1264E18001
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 18:36:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 94283E18004
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 18:36:24 +0900 (JST)
Date: Thu, 26 Nov 2009 18:33:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg: slab control
Message-Id: <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B0E461C.50606@parallels.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
	<20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
	<20091126085031.GG2970@balbir.in.ibm.com>
	<20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
	<4B0E461C.50606@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: balbir@linux.vnet.ibm.com, David Rientjes <rientjes@google.com>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Nov 2009 12:10:52 +0300
Pavel Emelyanov <xemul@parallels.com> wrote:

> >> Anyway, I agree that we need another
> >> slabcg, Pavel did some work in that area and posted patches, but they
> >> were mostly based and limited to SLUB (IIRC).
> 
> I'm ready to resurrect the patches and port them for slab.
> But before doing it we should answer one question.
> 
> Consider we have two kmalloc-s in a kernel code - one is
> user-space triggerable and the other one is not. From my
> POV we should account for the former one, but should not
> for the latter.
> 
> If so - how should we patch the kernel to achieve that goal?
> 
> > My point is that most of the kernel codes cannot work well when kmalloc(small area)
> > returns NULL.
> 
> :) That's not so actually. As our experience shows kernel lives fine
> when kmalloc returns NULL (this doesn't include drivers though).
> 
One issue it comes to my mind is that file system can return -EIO because
kmalloc() returns NULL. the kernel may work fine but terrible to users ;)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
