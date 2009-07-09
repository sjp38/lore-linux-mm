Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EB3B96B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:41:09 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8255982C4F6
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:18:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CZHuojdk+TRg for <linux-mm@kvack.org>;
	Thu,  9 Jul 2009 17:18:45 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5640582C508
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:18:33 -0400 (EDT)
Date: Thu, 9 Jul 2009 17:00:01 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <20090709111458.238C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907091647350.17835@gentwo.org>
References: <20090707101855.0C63.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907071248560.5124@gentwo.org> <20090709111458.238C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:

> >
> > Could you move the counters for reclaim into a separate cacheline?
> >
>
> Current definition is here.
>
> dirty pages and other frequently used counter stay in first cache line.
> NR_ISOLATED_(ANON|FILE) and other unfrequently used counter stay in second
> cache line.
>
> Do you mean we shouldn't use zone_stat_item for it?

No there is really no alternative to it.

Just be aware that what you may increases the cache footprint of key
functions in the vm. Some regression tests would be useful (do a page
fault test etc).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
