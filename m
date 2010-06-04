Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A84526B01B0
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 05:22:56 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o549MqeJ032676
	for <linux-mm@kvack.org>; Fri, 4 Jun 2010 02:22:52 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz5.hot.corp.google.com with ESMTP id o549MpqR008537
	for <linux-mm@kvack.org>; Fri, 4 Jun 2010 02:22:51 -0700
Received: by pzk9 with SMTP id 9so628240pzk.18
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 02:22:51 -0700 (PDT)
Date: Fri, 4 Jun 2010 02:22:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100604145723.e16d7fe0.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006040219350.26022@chino.kir.corp.google.com>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com> <20100602225252.F536.A69D9226@jp.fujitsu.com> <20100603161030.074d9b98.akpm@linux-foundation.org> <20100604085347.80c7b43f.kamezawa.hiroyu@jp.fujitsu.com>
 <20100603170443.011fdf7c.akpm@linux-foundation.org> <20100604092047.7b7d7bb1.kamezawa.hiroyu@jp.fujitsu.com> <20100604145723.e16d7fe0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010, KAMEZAWA Hiroyuki wrote:

> > In my personal observation
> > 
> >  [1/18]  for better behavior under cpuset.
> >  [2/18]  for better behavior under cpuset.
> >  [3/18]  for better behavior under mempolicy.
> >  [4/18]  refactoring.
> >  [5/18]  refactoring.
> >  [6/18]  clean up.
> >  [7/18]  changing the deault sysctl value.
> >  [8/18]  completely new logic.
> >  [9/18]  completely new logic.
> >  [10/18] a supplement for 8,9.
> >  [11/18] for better behavior under lowmem oom (disable oom kill)
> >  [12/18] clean up
> >  [13/18] bugfix for a possible race condition. (I'm not sure about details)
> >  [14/18] bugfix
> >  [15/18] bugfix
> >  [16/18] bugfix
> >  [17/18] bugfix
> >  [18/18] clean up.
> > 
> > If distro admins are aggresive, them may backport 1,2,3,7,11 but
> > it changes current logic. So, it's distro's decision.
> > 
> 
> IMHO, without considering HUNKs, the patch order should be
> 
>   13,14,15,16,17,1,2,3,7,11,4,5,6,18,12,8,9,10.
> 
> bugfix -> patches for things making better -> refactoring -> the new implementation.
> 

Thank you for very much for taking the time to look through each 
individual patch and suggest a different order.  If the ordering of the 
patches will help move us forward, then I'd be extremely happy to do it :)

> David, I have no objections to functions itself. But please start from small
> good things. "Refactoring" is good but it tend to make backporting
> not-straightforward. So, I think it should be done when there is no known issues.
> I think you can do.
> 

I'll reorganize the patchset itself without any implementation changes so 
it flows better and is more appropriately seperated as you suggest.  I 
still believe there is no -rc material within this series (implying there 
is no -stable material either), but if you believe so then please reply to 
those patches with the new posting so Andrew can consider pushing it to 
Linus.

Thanks Kame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
