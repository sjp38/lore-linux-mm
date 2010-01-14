Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F17A96B0092
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 02:14:15 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0E7EDpa019487
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Jan 2010 16:14:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6662045DE5D
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:14:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B0CE45DE57
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:14:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E33E1DB803B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:14:12 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 94E271DB8046
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:14:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH] mm: Restore zone->all_unreclaimable to independence word
In-Reply-To: <alpine.DEB.2.00.1001132229250.15428@chino.kir.corp.google.com>
References: <20100114103332.D71B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1001132229250.15428@chino.kir.corp.google.com>
Message-Id: <20100114161311.673B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Jan 2010 16:14:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 14 Jan 2010, KOSAKI Motohiro wrote:
> 
> > commit e815af95 (change all_unreclaimable zone member to flags) chage
> > all_unreclaimable member to bit flag. but It have undesireble side
> > effect.
> > free_one_page() is one of most hot path in linux kernel and increasing
> > atomic ops in it can reduce kernel performance a bit.
> > 
> > Thus, this patch revert such commit partially. at least
> > all_unreclaimable shouldn't share memory word with other zone flags.
> > 
> 
> I still think you need to quantify this; saying you don't have a large 
> enough of a machine that will benefit from it isn't really a rationale for 
> the lack of any data supporting your claim.  We should be basing VM 
> changes on data, not on speculation that there's a measurable impact 
> here.
> 
> Perhaps you could ask a colleague or another hacker to run a benchmark for 
> you so that the changelog is complete?

ok, fair. although I dislike current unnecessary atomic-ops.
I'll pending this patch until get good data.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
