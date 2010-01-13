Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E01E86B006A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 18:50:10 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0DNo84V003111
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 08:50:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E041245DE57
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:50:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B06FB45DE51
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:50:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BE061DB803E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:50:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 405831DB8040
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:50:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
In-Reply-To: <28c262361001130231k29b933der4022f4d1da80b084@mail.gmail.com>
References: <20100113171953.B3E5.A69D9226@jp.fujitsu.com> <28c262361001130231k29b933der4022f4d1da80b084@mail.gmail.com>
Message-Id: <20100114084659.D713.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 14 Jan 2010 08:50:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> Hi, Kosaki.
> 
> On Wed, Jan 13, 2010 at 5:21 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > Changelog
> > A from v1
> > A - get_anon_scan_ratio don't tak zone->lru_lock anymore
> > A  because zoneinfo_show_print takes zone->lock.
> 
> When I saw this changelog first, I got confused.
> That's because there is no relation between lru_lock and lock in zone.
> You mean zoneinfo is allowed to have a stale data?
> Tend to agree with it.

Well. zone->lock and zone->lru_lock should be not taked at the same time.
[1/4] of my last version removed zone->lock, then get_anon_scan_ratioo()
can take zone->lru_lock. but I dropped it. thus get_anon_scan_ration() can't
take zone->lru_lock.

Thus, I added need_update parameter.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
