Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F129E6B0098
	for <linux-mm@kvack.org>; Thu, 14 May 2009 21:46:13 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4F1kpw0027742
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 15 May 2009 10:46:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7640B45DE54
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:46:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5126D45DE56
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:46:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BF071DB8040
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:46:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4A9A1DB8037
	for <linux-mm@kvack.org>; Fri, 15 May 2009 10:46:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mmtom: Prevent shrinking of active anon lru list in case of no swap space V4
In-Reply-To: <4A0CC951.6070003@redhat.com>
References: <20090515103818.2c46d48a.minchan.kim@gmail.com> <4A0CC951.6070003@redhat.com>
Message-Id: <20090515104629.87ED.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 15 May 2009 10:46:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> Minchan Kim wrote:
> 
> > This patch prevents unnecessary deactivation of anon lru pages.
> > But, it doesn't prevent aging of anon pages to swap out.
> 
> >  Signed-off-by: barrios <minchan.kim@gmail.com>
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>

 Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
