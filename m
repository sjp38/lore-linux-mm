Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AA26A6B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 22:22:50 -0500 (EST)
Date: Fri, 23 Jan 2009 12:22:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Question: Is  zone->prev_prirotiy  used ?
In-Reply-To: <20090122090657.7c1d7b56.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090123084500.421C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090122090657.7c1d7b56.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090124122053.34E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, MinChan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > Kamezawa-san, does its variable prevent your development?
> > if so, I don't oppose removing.
> 
> Hmm, I tried to fix/clean up hierarchical-memory-reclaim + split-LRU and
> wondered where prev_priority should be recorded (hierarchy root or local or..)
> and found prev_priority is not used.
> 
> IMHO, LRU management is too complex to keep unnecessary code maintained just
> because it may be used in future. I personally like to rewrite better new code
> rather than reuse old ruins.

I can't oppose maintenar's opinion ;)
ok, I'll make the patch next week.


> 
> But I'm not in hurry. I just wanted to confirm.
> 
> BTW, I noticed mem_cgroup_calc_mapped_ratio() is not used, either ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
