Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 90C8F6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 03:09:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EAB4D3EE0C1
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:09:21 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D257B45DD74
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:09:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BC3D845DE4E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:09:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1EDF1DB803F
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:09:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7842D1DB803A
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:09:21 +0900 (JST)
Date: Thu, 28 Apr 2011 16:02:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
Message-Id: <20110428160249.79e67823.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinicqanpcVHtAWsgQxu1gkbzVpXdg@mail.gmail.com>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
	<20110428125739.15e252a7.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikgJWYJ8_rAkuNtD0vTehCG7vPpow@mail.gmail.com>
	<20110428132757.130b4206.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinicqanpcVHtAWsgQxu1gkbzVpXdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 27 Apr 2011 21:40:06 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 27, 2011 at 9:27 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 27 Apr 2011 21:24:30 -0700
> > Ying Han <yinghan@google.com> wrote:

> > BTW, ff I add more statistics, I'll add per-node statistics.
> > Hmm, memory.node_stat is required ?
> 
> Yes and this will be useful. One of the stats I would like add now is
> the number of pages allocated on behalf of the memcg per numa node.
> This is a piece of useful information to evaluate the numa locality
> correlated to the application
> performance.
> 
> I was wondering where to add the stats and memory.stat seems not to be
> the best fit. If we have memory.node_stat, that would be a good place
> for those kind of info?
> 

Maybe it's better to add memory.node_stat ....memory.stat seems a bit long ;)
I'd like to consider to add a tool to grab information easily under somewhere
...as cgroup-top.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
