Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id ECB116B02DD
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 07:09:51 -0400 (EDT)
Received: by yenr5 with SMTP id r5so2896880yen.14
        for <linux-mm@kvack.org>; Sun, 24 Jun 2012 04:09:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE5E66C.6080309@redhat.com>
References: <4FE012CD.6010605@kernel.org> <4FE37434.808@linaro.org>
 <4FE41752.8050305@kernel.org> <4FE549E8.2050905@jp.fujitsu.com> <4FE5E66C.6080309@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 24 Jun 2012 07:09:30 -0400
Message-ID: <CAHGf_=rqTnmm-kTBZQs8NwOX2yKh=fxJ58-uPcL6cb7K3tk9Og@mail.gmail.com>
Subject: Re: RFC: Easy-Reclaimable LRU list
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Hugh Dickins <hughd@google.com>

On Sat, Jun 23, 2012 at 11:53 AM, Rik van Riel <riel@redhat.com> wrote:
> On 06/23/2012 12:45 AM, Kamezawa Hiroyuki wrote:
>
>> I think this is interesting approach. Major concern is how to guarantee
>> EReclaimable
>> pages are really EReclaimable...Do you have any idea ? madviced pages
>> are really EReclaimable ?
>
> I suspect the EReclaimable pages can only be clean page
> cache pages that are not mapped by any processes.
>
> Once somebody tries to use the page, mark_page_accessed
> will move it to another list.

100% agree.


>> A (very) small concern is will you use one more page-flags for this ? ;)
>
> This could be an issue on a 32 bit system, true.

Do we really need SwapBacked bit? Actually swap-backed is
per-superblock attribute and don't change dynamically (i.e. no race
happen). thus this bit
might be able to move into page->mapping or page->mapping->host.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
