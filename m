Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 007206B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 22:13:59 -0400 (EDT)
Message-ID: <4BD64848.9070604@redhat.com>
Date: Mon, 26 Apr 2010 22:13:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
References: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>	<1272321478-28481-3-git-send-email-mel@csn.ul.ie>	<4BD63031.6050105@redhat.com> <20100427093136.4de21a47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100427093136.4de21a47.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/26/2010 08:31 PM, KAMEZAWA Hiroyuki wrote:

>> If you're part way down the list, surely you'll need to
>> unlock multiple anon_vmas here before going to retry?
>>
> vma->anon_vma->lock is released after vma_address().

Doh, never mind.  Too much code in my mind at once...

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
