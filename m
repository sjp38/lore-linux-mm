Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 700886B02C2
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 11:53:31 -0400 (EDT)
Message-ID: <4FE5E66C.6080309@redhat.com>
Date: Sat, 23 Jun 2012 11:53:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: RFC:  Easy-Reclaimable LRU list
References: <4FE012CD.6010605@kernel.org> <4FE37434.808@linaro.org> <4FE41752.8050305@kernel.org> <4FE549E8.2050905@jp.fujitsu.com>
In-Reply-To: <4FE549E8.2050905@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

On 06/23/2012 12:45 AM, Kamezawa Hiroyuki wrote:

> I think this is interesting approach. Major concern is how to guarantee
> EReclaimable
> pages are really EReclaimable...Do you have any idea ? madviced pages
> are really EReclaimable ?

I suspect the EReclaimable pages can only be clean page
cache pages that are not mapped by any processes.

Once somebody tries to use the page, mark_page_accessed
will move it to another list.

> A (very) small concern is will you use one more page-flags for this ? ;)

This could be an issue on a 32 bit system, true.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
