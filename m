Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B01546B010C
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 04:45:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D8jBR5018976
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 17:45:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99F0345DE52
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 17:45:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7EE8645DD71
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 17:45:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 680BC1DB8012
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 17:45:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C328E38001
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 17:45:11 +0900 (JST)
Date: Wed, 13 Oct 2010 17:39:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] contigous big page allocator
Message-Id: <20101013173950.0521c849.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <87ocay1obe.fsf@basil.nowhere.org>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<87sk0a1sq0.fsf@basil.nowhere.org>
	<20101013161206.c29df8ea.kamezawa.hiroyu@jp.fujitsu.com>
	<87ocay1obe.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, fujita.tomonori@lab.ntt.co.jp
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010 10:36:53 +0200
Andi Kleen <andi@firstfloor.org> wrote:

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
> 
> (maybe we need some way to indicate how hard the freeing code should
> try?)
> 
yes. I think this patch should be update to do a precice control of memory
pressure. It will improve memory hotplug's memory allocation, too.


> I guess it would only really work well if you predefine
> movable zones at boot time.
> 

I think so, too. But maybe enough for embeded guys and very special systems
which need to use 1G page.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
