Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 953396B007E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 00:18:56 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E5IrJG019284
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 14:18:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 86A1D45DE52
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:18:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 66D3145DE53
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:18:53 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 500901DB803E
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:18:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B26EE08002
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 14:18:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3][v2] vmstat: add anon_scan_ratio field to zoneinfo
In-Reply-To: <28c262361001132112i7f50fd66qcd24dc2ddb4d78d8@mail.gmail.com>
References: <20100114084659.D713.A69D9226@jp.fujitsu.com> <28c262361001132112i7f50fd66qcd24dc2ddb4d78d8@mail.gmail.com>
Message-Id: <20100114141735.672B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 14 Jan 2010 14:18:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > Well. zone->lock and zone->lru_lock should be not taked at the same time.
> 
> I looked over the code since I am out of office.
> I can't find any locking problem zone->lock and zone->lru_lock.
> Do you know any locking order problem?
> Could you explain it with call graph if you don't mind?
> 
> I am out of office by tomorrow so I can't reply quickly.
> Sorry for late reponse.

This is not lock order issue. both zone->lock and zone->lru_lock are
hotpath lock. then, same tame grabbing might cause performance impact.

thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
