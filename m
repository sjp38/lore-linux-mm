Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CC8FD6B0071
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 21:16:14 -0500 (EST)
Message-ID: <4B53C466.4010103@redhat.com>
Date: Sun, 17 Jan 2010 21:16:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
References: <20100118100359.AE22.A69D9226@jp.fujitsu.com>	 <28c262361001171747w450c8fd8j4daf84b72fb68e1a@mail.gmail.com>	 <20100118104910.AE2D.A69D9226@jp.fujitsu.com> <28c262361001171810w544614b7rdd3df0f984692f35@mail.gmail.com>
In-Reply-To: <28c262361001171810w544614b7rdd3df0f984692f35@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/17/2010 09:10 PM, Minchan Kim wrote:

> Absoultely right. I missed that. Thanks.
> get_scan_ratio used lru_lock to get reclaim_stat->recent_xxxx.
> But, it doesn't used lru_lock to get ap/fp.
>
> Is it intentional? I think you or Rik know it. :)
> I think if we want to get exact value, we have to use lru_lock until
> getting ap/fp.
> If it isn't, we don't need lru_lock when we get the reclaim_stat->recent_xxxx.
>
> What do you think about it?

This is definately not intentional.

Getting race conditions in this code could throw off the
statistics by a factor 2.  I do not know how serious that
would be for the VM or whether (and how quickly) it would
self correct.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
