Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6183E6B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 21:04:16 -0500 (EST)
Message-ID: <4CE4897F.4020107@redhat.com>
Date: Wed, 17 Nov 2010 21:03:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim during
 high-order allocations
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <20101117154641.51fd7ce5.akpm@linux-foundation.org>
In-Reply-To: <20101117154641.51fd7ce5.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/17/2010 06:46 PM, Andrew Morton wrote:
> On Wed, 17 Nov 2010 16:22:41 +0000
> Mel Gorman<mel@csn.ul.ie>  wrote:

>> I'm hoping that this series also removes the
>> necessity for the "delete lumpy reclaim" patch from the THP tree.
>
> Now I'm sad.  I read all that and was thinking "oh goody, we get to
> delete something for once".  But no :(
>
> If you can get this stuff to work nicely, why can't we remove lumpy
> reclaim?

I seem to remember there being some resistance against
removing lumpy reclaim, but I do not remember from
where or why.

IMHO some code deletion would be nice :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
