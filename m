Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 176946B0207
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 00:23:48 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G4NjOU023372
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Apr 2010 13:23:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D2D4145DE51
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 13:23:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AC99645DE4E
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 13:23:44 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 85FFC1DB8013
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 13:23:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BD90E08010
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 13:23:41 +0900 (JST)
Date: Fri, 16 Apr 2010 13:18:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-Id: <20100416131823.c874125a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100416101339.a501f554.kamezawa.hiroyu@jp.fujitsu.com>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
	<20100416101339.a501f554.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Apr 2010 10:13:39 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
 
> Hmm. Then, if memoy cgroup is filled by dirty pages, it can't kick writeback
> and has to wait for someone else's writeback ?
> 
> How long this will take ?
> # mount -t cgroup none /cgroup -o memory
> # mkdir /cgroup/A
> # echo 20M > /cgroup/A/memory.limit_in_bytes
> # echo $$ > /cgroup/A/tasks
> # dd if=/dev/zero of=./tmpfile bs=4096 count=1000000
> 
> Can memcg ask writeback thread to "Wake Up Now! and Write this out!" effectively ?
> 

Hmm.. I saw an oom-kill while testing several cases but performance itself
seems not to be far different with or without patch.
But I'm unhappy with oom-kill, so some tweak for memcg will be necessary
if we'll go with this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
