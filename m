Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 650B26B009F
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 22:59:14 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n693CWl1013890
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 12:12:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C53945DE53
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:12:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D0BE45DE51
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:12:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 679ADE08006
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:12:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BD03BE08004
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 12:12:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH 1/2] vmscan don't isolate too many pages
In-Reply-To: <28c262360907071639g4877b2c2w59a8eae8559557f7@mail.gmail.com>
References: <20090707184034.0C70.A69D9226@jp.fujitsu.com> <28c262360907071639g4877b2c2w59a8eae8559557f7@mail.gmail.com>
Message-Id: <20090709121123.2392.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 12:12:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> > + ? ? ? if (too_many_isolated(gfp_mask, zonelist, high_zoneidx, nodemask)) {
> 
> too_many_isolated(zonelist, high_zoneidx, nodemask)

Correct.
I forgot to quilt refresh before sending. sorry.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
