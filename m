Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 54F6A6B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 09:14:11 -0400 (EDT)
Message-ID: <4C975E01.3070503@redhat.com>
Date: Mon, 20 Sep 2010 09:13:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: cgroup oom regression introduced by 6a5ce1b94e1e5979f8db579f77d6e08a5f44c13b
References: <1296415999.1298271284814035815.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <290491919.1298351284814354705.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <20100918152120.GA21343@barrios-desktop>
In-Reply-To: <20100918152120.GA21343@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: caiqian@redhat.com, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "M. Vefa Bicakci" <bicave@superonline.com>, Johannes Weiner <hannes@cmpxchg.org>, stable@kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 09/18/2010 11:21 AM, Minchan Kim wrote:

> When memory pressure in memcg is high, do_try_to_free_pages returns
> 0. It causes mem_cgroup_out_of_memory so that any process in mem group
> would be killed.
> But vmscan-check-all_unreclaimable-in-direct-reclaim-path.patch changed
> the old behavior. It returns 1 unconditionally regardless of considering
> global reclaim or memcg relcaim. It causes hang without triggering OOM
> in case of memcg direct reclaim.
>
> This patch fixes it.
>
> It's reported by caiqian@redhat.com.
> (Thanks. Totally, it's my fault.)
>
> Reported-by: caiqian@redhat.com
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Balbir Singh<balbir@in.ibm.com>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
