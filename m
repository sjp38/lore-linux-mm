Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 0CFB36B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 23:56:07 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1D5F83EE0AE
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 13:56:06 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 033E245DF47
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 13:56:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E1C8945DEA1
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 13:56:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4CDB1DB802F
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 13:56:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C7731DB803B
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 13:56:05 +0900 (JST)
Date: Wed, 1 Feb 2012 13:54:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] memcg: soft limit reclaim (continue)
 and others
Message-Id: <20120201135442.0491d882.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4iypV=k-7gVcFx=OsHJsWcUzQsfEoYbQ4+ySQoTob_PWcQ@mail.gmail.com>
References: <CALWz4iypV=k-7gVcFx=OsHJsWcUzQsfEoYbQ4+ySQoTob_PWcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, 31 Jan 2012 11:59:40 -0800
Ying Han <yinghan@google.com> wrote:

> some topics that I would like to discuss this year:
> 
> 1) we talked about soft limit redesign during last LSF, and there are
> quite a lot of efforts and changes being pushed after that. I would
> like to take this time to sync-up our efforts and also discuss some of
> the remaining issues.
> 
> Discussion from last year :
> http://www.spinics.net/lists/linux-mm/msg17102.html and lots of
> changes have been made since then.
> 

Yes, it seems re-sync is required.

> 2) memory.stat, this is the main stat file for all memcg statistics.
> are we planning to keep stuff it for something like per-memcg
> vmscan_stat, vmstat or not.
> 

Could you calrify ? Do you want to have another stat file like memory.vmstat ?


> 3) root cgroup now becomes quite interesting, especially after we
> bring back the exclusive lru to root. To be more specific, root cgroup
> now is like a sink which contains pages allocated on its own, and also
> pages being re-parented. Those pages won't be reclaimed until there is
> a global pressure, and we want to see anything we can do better.
> 

I'm sorry I can't get your point. 

Do you think it's better to shrink root mem cgroup LRU even if there are
no memory pressure ? The benefit will be reduced memory reclaim latency.
Or Do you think root memcg should have some soft limit and should be
reclaimed in the same schedule line as other memcgs ? The benefit will be fairness.

or other idea ?

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
