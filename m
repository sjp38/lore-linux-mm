Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A7826B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 22:12:17 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0L3CEFr009034
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 21 Jan 2010 12:12:14 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6230445DE56
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:12:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB11A45DE53
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:12:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD5A11DB8044
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:12:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 383ED1DB8040
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:12:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC-PATCH 0/7] Memory Compaction v1
In-Reply-To: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie>
Message-Id: <20100121115636.73BA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 21 Jan 2010 12:12:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

Sorry, I haven't read this patch at all.

> The time differences are marginal but bear in mind that this is an ideal
> case of mostly unmapped buffer pages. On nice set of results is between
> allocations 13-18 where no pages were reclaimed, some compaction occured
> and 300 huge pages were allocated in 0.16 seconds. Furthermore, compaction
> allocated a high higher percentage of memory (91% of RAM as huge pages).
> 
> The downside appears to be that the compaction kernel reclaimed even more
> pages than the vanilla kernel. However, take the cut-off point of 880 pages
> that both kernels succeeded. The vanilla kernel had reclaimed 105132 pages
> at that point. The kernel with compaction had reclaimed 59071, less than
> half of what the vanilla kernel reclaimed. i.e. the bulk of pages reclaimed
> with the compaction kernel were to get from 87% of memory allocated to 91%
> as huge pages.
> 
> These results would appear to be an encouraging enough start.
> 
> Comments?

I think "Total pages reclaimed" increasing is not good thing ;)
Honestly, I haven't understand why your patch increase reclaimed and
the exactly meaning of the your tool's rclm field.

Can you share your mesurement script? May I run the same test?

I like this patch, but I don't like increasing reclaim. I'd like to know
this patch require any vmscan change and/or its change mitigate the issue.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
