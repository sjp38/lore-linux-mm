Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2688D0040
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 05:39:17 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AFE6C3EE0C0
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:39:13 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9215345DE50
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:39:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 766F245DE4E
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:39:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6696A1DB803B
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:39:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31E481DB802F
	for <linux-mm@kvack.org>; Sun,  3 Apr 2011 18:39:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110401180455.GU2879@balbir.in.ibm.com>
References: <20110401222250.A894.A69D9226@jp.fujitsu.com> <20110401180455.GU2879@balbir.in.ibm.com>
Message-Id: <20110403183927.AE4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  3 Apr 2011 18:39:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

> > > > Hm. OK, I may misread.
> > > > Can you please explain the reason why de-duplication feature need to selectable and
> > > > disabled by defaut. "explicity enable" mean this feature want to spot corner case issue??
> > > 
> > > Yes, because given a selection of choices (including what you
> > > mentioned in the review), it would be nice to have
> > > this selectable.
> > 
> > It's no good answer. :-/
> 
> I am afraid I cannot please you with my answers
> 
> > Who need the feature and who shouldn't use it? It this enough valuable for enough large
> > people? That's my question point.
> > 
> 
> You can see the use cases documented, including when running Linux as
> a guest under other hypervisors, 

Which hypervisor? If this patch is unrelated 99.9999% people, shouldn't you have to reduce
negative impact?


> today we have a choice of not using
> host page cache with cache=none, but nothing the other way round.
> There are other use cases for embedded folks (in terms of controlling
> unmapped page cache), please see previous discussions.

Is there other usecase? really? Where exist?
Why do you start to talk about embedded sudenly? I reviewed this as virtualization feature
beucase you wrote so in [path 0/3]. Why do you change your point suddenly?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
