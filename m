Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9BAE06B005C
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:16:27 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id j3so2968937tid.8
        for <linux-mm@kvack.org>; Wed, 21 Jan 2009 16:16:25 -0800 (PST)
Date: Thu, 22 Jan 2009 09:15:32 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: Question: Is  zone->prev_prirotiy  used ?
Message-ID: <20090122001532.GC17969@barrios-desktop>
References: <20090121155219.8b870167.kamezawa.hiroyu@jp.fujitsu.com> <20090121071718.GA17969@barrios-desktop> <20090123084500.421C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090122090657.7c1d7b56.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090122090657.7c1d7b56.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jan 22, 2009 at 09:06:57AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 22 Jan 2009 08:54:07 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Wed, Jan 21, 2009 at 03:52:19PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > Just a question.
> > > > 
> > > > In vmscan.c,  zone->prev_priority doesn't seem to be used.
> > > > 
> > > > Is it for what, now ?
> > > 
> > > It's the purpose of reclaiming mapped pages before split-lru.
> > > Now, get_scan_ratio can do it. 
> > > I think it is a meaningless variable.
> > > How about Kosaki and Rik ?
> > 
> > Right.
> > I thought this variable can use for future enhancement. 
> > then I didn't removed.
> > 
> example ?
> 
> > Kamezawa-san, does its variable prevent your development?
> > if so, I don't oppose removing.
> > 
> 
> Hmm, I tried to fix/clean up hierarchical-memory-reclaim + split-LRU and
> wondered where prev_priority should be recorded (hierarchy root or local or..)
> and found prev_priority is not used.
> 
> IMHO, LRU management is too complex to keep unnecessary code maintained just
> because it may be used in future. I personally like to rewrite better new code
> rather than reuse old ruins.

I agree. It's too complicated. 
I think it would be better to remove it. 
We can insert it again when we will really need it. 
 
> But I'm not in hurry. I just wanted to confirm.
> 
> BTW, I noticed mem_cgroup_calc_mapped_ratio() is not used, either ;)
> 
> Thanks,
> -Kame

--
Kinds Regards,
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
