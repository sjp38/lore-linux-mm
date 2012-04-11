Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 5DAB06B007E
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:56:22 -0400 (EDT)
Message-ID: <4F85C813.2050206@redhat.com>
Date: Wed, 11 Apr 2012 14:06:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Removal of lumpy reclaim V2
References: <1334162298-18942-1-git-send-email-mgorman@suse.de> <4F85BC8E.3020400@redhat.com> <20120411175215.GI3789@suse.de>
In-Reply-To: <20120411175215.GI3789@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/11/2012 01:52 PM, Mel Gorman wrote:
> On Wed, Apr 11, 2012 at 01:17:02PM -0400, Rik van Riel wrote:

>> Next step: get rid of __GFP_NO_KSWAPD for THP, first
>> in the -mm kernel
>>
>
> Initially the flag was introduced because kswapd reclaimed too
> aggressively. One would like to believe that it would be less of a problem
> now but we must avoid a situation where the CPU and reclaim cost of kswapd
> exceeds the benefit of allocating a THP.

Since kswapd and the direct reclaim code now use
the same conditionals for calling compaction,
the cost ought to be identical.

I agree this is something we should shake out
in -mm for a while though, before considering a
mainline merge.

Andrew, would you be willing to take a removal
of __GFP_NO_KSWAPD in -mm, and push it to Linus
for the 3.6 kernel if no ill effects are seen
in -mm and -next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
