Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 940E76B0120
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 21:59:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9E1x89d031467
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Oct 2010 10:59:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DD2945DE51
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 10:59:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14D7745DE4D
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 10:59:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E42A71DB8040
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 10:59:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 520291DB8038
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 10:59:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
In-Reply-To: <87ocay1obe.fsf@basil.nowhere.org>
References: <20101013161206.c29df8ea.kamezawa.hiroyu@jp.fujitsu.com> <87ocay1obe.fsf@basil.nowhere.org>
Message-Id: <20101014105521.8B80.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Oct 2010 10:59:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, fujita.tomonori@lab.ntt.co.jp
List-ID: <linux-mm.kvack.org>

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> >> >   My intention is not for allocating HUGEPAGE(> MAX_ORDER).
> >> 
> >> I still believe using this for 1GB pages would be one of the more
> >> interesting use cases.
> >> 
> >
> > I'm successfully allocating 1GB of continous pages at test. But I'm not sure
> > requirements and users. How quick this allocation should be ?
> 
> This will always be slow. Huge pages are always pre allocated
> even today through a sysctl. The use case would be have
> 
> echo XXX > /proc/sys/vm/nr_hugepages 
> 
> at runtime working for 1GB too, instead of requiring a reboot
> for this. 
> 
> I think it's ok if that is somewhat slow, as long as it is not
> incredible slow. Ideally it shouldn't cause a swap storm either 

offtopic: When I tried to increase nr_hugepages on ia64
which has 256MB hugepage architecture, sometimes I needed to wait
>10 miniture if the system is under memory pressure. So, slow allocation
is NOT only this contigous allocator issue. we already accept it and
we should. (I doubt it can be avoidable)



> 
> (maybe we need some way to indicate how hard the freeing code should
> try?)
> 
> I guess it would only really work well if you predefine
> movable zones at boot time.
> 
> -Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
