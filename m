Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 435B260079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 18:57:47 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB9NvZOl000848
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 08:57:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD76B45DE52
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:57:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D7D345DE50
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:57:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A5921DB8042
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:57:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 099CA1DB803E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 08:57:35 +0900 (JST)
Date: Thu, 10 Dec 2009 08:54:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-Id: <20091210085413.0fe4369e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091209161219.GV28697@random.random>
References: <20091202125501.GD28697@random.random>
	<20091203134610.586E.A69D9226@jp.fujitsu.com>
	<20091204135938.5886.A69D9226@jp.fujitsu.com>
	<20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
	<20091204171640.GE19624@x200.localdomain>
	<20091209094331.a1f53e6d.kamezawa.hiroyu@jp.fujitsu.com>
	<20091209161219.GV28697@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Wright <chrisw@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009 17:12:19 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Wed, Dec 09, 2009 at 09:43:31AM +0900, KAMEZAWA Hiroyuki wrote:
> > cache-line ping-pong at fork beacause of page->mapcount. And KSM introduces
> > zero-pages which have mapcount again. If no problems in realitsitc usage of
> > KVM, ignore me.
> 
> The whole memory marked MADV_MERGEABLE by KVM is also marked
> MADV_DONTFORK, so if KVM was to fork (and if it did, if it wasn't for
> MADV_DONTFORK, it would also trigger all O_DIRECT vs fork race
> conditions too, as KVM is one of the many apps that uses threads and
> O_DIRECT - we try not to fork though but we sure did in the past), no
> slowdown could ever happen in mapcount because of KSM, all KSM pages
> aren't visibile by child.
> 
> It's still something to keep in mind for other KSM users, but I don't
> think mapcount is big deal if compared to the risk of triggering COWs
> later on those pages, in general KSM is all about saving tons of
> memory at the expense of some CPU cycle (kksmd, cows, mapcount with
> parallel forks etc...).
> 
Okay, thank you for kindlt explanation.

and sorry for noise.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
