Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F22356B0071
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 21:24:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I2OrWA023195
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 11:24:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AC8A45DE64
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:24:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3357B45DE5D
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:24:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 095C61DB8038
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:24:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B09E1DB8041
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 11:24:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
In-Reply-To: <4B53C466.4010103@redhat.com>
References: <28c262361001171810w544614b7rdd3df0f984692f35@mail.gmail.com> <4B53C466.4010103@redhat.com>
Message-Id: <20100118112359.AE3C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 18 Jan 2010 11:24:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On 01/17/2010 09:10 PM, Minchan Kim wrote:
> 
> > Absoultely right. I missed that. Thanks.
> > get_scan_ratio used lru_lock to get reclaim_stat->recent_xxxx.
> > But, it doesn't used lru_lock to get ap/fp.
> >
> > Is it intentional? I think you or Rik know it. :)
> > I think if we want to get exact value, we have to use lru_lock until
> > getting ap/fp.
> > If it isn't, we don't need lru_lock when we get the reclaim_stat->recent_xxxx.
> >
> > What do you think about it?
> 
> This is definately not intentional.

Really?
So, I'll post next patch.

Thanks.



> Getting race conditions in this code could throw off the
> statistics by a factor 2.  I do not know how serious that
> would be for the VM or whether (and how quickly) it would
> self correct.
> 
> -- 
> All rights reversed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
