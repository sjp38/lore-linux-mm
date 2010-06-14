Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 044FA6B01AF
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 03:04:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5E74tee029659
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 14 Jun 2010 16:04:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CEA745DE55
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:04:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BA4145DE4F
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:04:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFE9AE0800D
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:04:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B3ADE08001
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 16:04:50 +0900 (JST)
Date: Mon, 14 Jun 2010 16:00:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] Linux/Guest unmapped page cache control
Message-Id: <20100614160021.7febbdb2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100614064955.GR5191@balbir.in.ibm.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	<20100608155146.3749.67837.sendpatchset@L34Z31A.ibm.com>
	<20100613183145.GM5191@balbir.in.ibm.com>
	<20100614092819.cb7515a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20100614064955.GR5191@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kvm <kvm@vger.kernel.org>, Avi Kivity <avi@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 2010 12:19:55 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > - Why don't you believe LRU ? And if LRU doesn't work well, should it be
> >   fixed by a knob rather than generic approach ?
> > - No side effects ?
> 
> I believe in LRU, just that the problem I am trying to solve is of
> using double the memory for caching the same data (consider kvm
> running in cache=writethrough or writeback mode, both the hypervisor
> and the guest OS maintain a page cache of the same data). As the VM's
> grow the overhead is substantial. In my runs I found upto 60%
> duplication in some cases.
> 
> 
> - Linux vm guys tend to say, "free memory is bad memory". ok, for what
>   free memory created by your patch is used ? IOW, I can't see the benefit.
>   If free memory that your patch created will be used for another page-cache,
>   it will be dropped soon by your patch itself.
> 
> Free memory is good for cases when you want to do more in the same
> system. I agree that in a bare metail environment that might be
> partially true. I don't have a problem with frequently used data being
> cached, but I am targetting a consolidated environment at the moment.
> Moreover, the administrator has control via a boot option, so it is
> non-instrusive in many ways.

It sounds that what you want is to improve performance etc. but to make it
easy sizing the system and to help admins. Right ?

>From performance perspective, I don't see any advantage to drop caches
which can be dropped easily. I just use cpus for the purpose it may no
be necessary.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
