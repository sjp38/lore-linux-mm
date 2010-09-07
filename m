Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A34D76B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 04:31:14 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o878VBL2023996
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Sep 2010 17:31:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AE7145DE58
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 17:31:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 64FFE45DE51
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 17:31:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4618AE38002
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 17:31:10 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 84B05E08005
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 17:31:06 +0900 (JST)
Date: Tue, 7 Sep 2010 17:25:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] big continuous memory allocator v2
Message-Id: <20100907172559.496554d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <87occa9fla.fsf@basil.nowhere.org>
References: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
	<87occa9fla.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 07 Sep 2010 09:29:21 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > This is a page allcoator based on memory migration/hotplug code.
> > passed some small tests, and maybe easier to read than previous one.
> 
> Maybe I'm missing context here, but what is the use case for this?
> 

I hear some drivers want to allocate xxMB of continuous area.(camera?)
Maybe embeded guys can answer the question.

> If this works well enough the 1GB page code for x86, which currently
> only supports allocating at boot time due to the MAX_ORDER problem,
> could be moved over to runtime allocation. This would make
> GB pages a lot nicer to use.
> 
> I think it would still need declaring a large moveable
> area at boot right? (but moveable area is better than
> prereserved memory)
> 
Right.  

I think a main use-case is using allocation-at-init rather than boot
option. If modules can allocate a big chunk in __init_module() at boot,
boot option will not be necessary and it will be user friendly.
I think there are big free space before application starts running.

If on-demand loading of modules are required, it's safe to use MOVABLE zones.

> On the other hand I'm not sure the VM is really up to speed
> in managing such large areas.
> 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
