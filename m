Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6ACB76B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:24:01 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 31D7B82C508
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:01:40 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id M3YSQtFKg4dk for <linux-mm@kvack.org>;
	Thu,  9 Jul 2009 17:01:40 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 65AF882C50A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:01:35 -0400 (EDT)
Date: Thu, 9 Jul 2009 16:43:02 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <20090709171247.23C6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907091638330.17835@gentwo.org>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709171247.23C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:

> Subject: [PATCH] add isolate pages vmstat
>
> If the system have plenty threads or processes, concurrent reclaim can
> isolate very much pages.
> Unfortunately, current /proc/meminfo and OOM log can't show it.

"
If the system is running a heavy load of processes then concurrent reclaim
can isolate a large numbe of pages from the LRU. /proc/meminfo and the
output generated for an OOM do not show how many pages were isolated.
"

> This patch provide the way of showing this information.

"
This patch shows the information about isolated pages.
"


Page migration can also isolate a large number of pages from the LRU. But
the new counters are not used there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
