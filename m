Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 668FC6B0023
	for <linux-mm@kvack.org>; Thu, 12 May 2011 04:24:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 42A283EE0BC
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:24:10 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A07B45DD6E
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:24:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED45745DE4E
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:24:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9E441DB8043
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:24:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C4D01DB802C
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:24:09 +0900 (JST)
Date: Thu, 12 May 2011 17:17:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
Message-Id: <20110512171725.d367980f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110512132237.813a7c7f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
	<20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511205110.354fa05e.akpm@linux-foundation.org>
	<20110512132237.813a7c7f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, 12 May 2011 13:22:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 11 May 2011 20:51:10 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:

> Ah, sorry. above was on KVM.  without container.
> ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx
> 
> real    0m5.197s
> user    0m0.006s
> sys     0m2.599s
> ==
> Hmm, still slow. I'll use real hardware in the next post.
> 

I'm now testing on a real machine with some fixes and see

== without async reclaim ==
real    0m6.569s
user    0m0.006s
sys     0m0.976s

== with async reclaim ==
real    0m6.305s
user    0m0.007s
sys     0m0.907s

...in gneral sys time reduced always but 'real' is in error range ;)
yes, no gain.

I'll check what codes in vmscan.c or /mm affects memcg and post a
required fix in step by step. I think I found some..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
