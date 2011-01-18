Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 391318D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:37:47 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7A7FD3EE0B3
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:37:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E3A945DE58
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:37:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4682045DE57
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:37:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A9C7E08003
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:37:44 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 02708E08002
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 11:37:44 +0900 (JST)
Date: Tue, 18 Jan 2011 11:31:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] fix THP and memcg issues v2.
Message-Id: <20110118113148.77d5c0df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110118110604.e2528324.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110118110604.e2528324.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 11:06:04 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> Now, when THP is enabled, memcg's counter goes wrong. Moreover, rmdir()
> may not end. I fixed some races since v1.
> 
> 
> This series is a fix for obviouse counter breakage. When you test,
> CONFIG_TRANSPARENT_HUGEPAGE=y
> CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
> 
> is appreciated. Tests should be done is:
> 
> # mount -t cgroup none /cgroup/memory -omemory
> # mkdir /cgroup/memory/A
> # mkdir /cgroup/memory/A/B
> # run some programs under B.
> # echo 0 > /cgroup/memory/A/B/memory.force_empty
> 
> and check B's memory.stat shows RSS/CACHE/LRU are all 0.
> Moving tasks while running is another good test.
> 
> I know there are another problem when memory cgroup hits limit and
> reclaim in busy. But I will fix it in another patch.
> 

I found some mistake of patch handling in patch 2/4 and 3/4.
(a code for 2/4 was in 3/4...)
I'll send v3. I'm sorry.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
