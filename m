Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8A98E6B005C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 03:40:45 -0400 (EDT)
Date: Tue, 9 Jun 2009 09:08:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when
	zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
Message-ID: <20090609080842.GC18380@csn.ul.ie>
References: <1244466090-10711-1-git-send-email-mel@csn.ul.ie> <1244466090-10711-2-git-send-email-mel@csn.ul.ie> <4A2D129D.3020309@redhat.com> <20090608135433.GD15070@csn.ul.ie> <4A2D24B0.4080301@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4A2D24B0.4080301@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 10:48:16AM -0400, Rik van Riel wrote:
> Mel Gorman wrote:
>> On Mon, Jun 08, 2009 at 09:31:09AM -0400, Rik van Riel wrote:
>>> Mel Gorman wrote:
>>>
>>>> The scanning occurs because zone_reclaim() cannot tell
>>>> in advance the scan is pointless because the counters do not distinguish
>>>> between pagecache pages backed by disk and by RAM. 
>>> Yes it can.  Since 2.6.27, filesystem backed and swap/ram backed
>>> pages have been living on separate LRU lists. 
>>
>> Yes, they're on separate LRU lists but they are not the only pages on those
>> lists. The tmpfs pages are mixed in together with anonymous pages so we
>> cannot use NR_*_ANON.
>>
>> Look at patch 2 and where I introduced;
>
> I have to admit I did not read patches 2 and 3 before
> replying to the (strange looking, at the time) text
> above patch 1.
>

Sorry about that. The ordering of the patches was in "patch that fixes
bug, patch that addresses expectations and patch that fixes imaginery
bug but that makes sense". If it was a real patchset, patch 2 would have
come first.

> With that logic from patch 2 in place, patch 1 makes
> perfect sense.
>
> Acked-by: Rik van Riel <riel@redhat.com>
>

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
