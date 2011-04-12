Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 428998D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 06:55:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F091E3EE081
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:55:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5AE445DE99
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:55:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA91045DE92
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:55:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A9D1BE08006
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:55:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 753F0E08004
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 19:55:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmscan: all_unreclaimable() use zone->all_unreclaimable as a name
In-Reply-To: <20110411182606.016f9486.akpm@linux-foundation.org>
References: <20110412100417.43F2.A69D9226@jp.fujitsu.com> <20110411182606.016f9486.akpm@linux-foundation.org>
Message-Id: <20110412195513.B533.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Apr 2011 19:55:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

Hi

> > The above says "Eventually, oom-killer never works". Is this no enough?
> > The above says
> >   1) current logic have a race
> >   2) x86 increase a chance of the race by dma zone
> >   3) if race is happen, oom killer don't work
> 
> And the system hangs up, so it's a local DoS and I guess we should
> backport the fix into -stable.  I added this:
> 
> : This resulted in the kernel hanging up when executing a loop of the form
> : 
> : 1. fork
> : 2. mmap
> : 3. touch memory
> : 4. read memory
> : 5. munmmap
> : 
> : as described in
> : http://www.gossamer-threads.com/lists/linux/kernel/1348725#1348725
> 
> And the problems which the other patches in this series address are
> pretty deadly as well.  Should we backport everything?

patch [1/4] and [2/4] should be backported because they are regression fix.
But [3/4] and [4/4] are on borderline to me. they improve a recovery time 
from oom. some times it is very important, some times not. And it is not
regression fix. Our oom-killer is very weak from forkbomb attack since
very old days.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
