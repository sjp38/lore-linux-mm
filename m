Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 08C41900146
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 20:26:54 -0400 (EDT)
Message-ID: <4E4321C5.7030907@redhat.com>
Date: Wed, 10 Aug 2011 20:26:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3 of 3] thp: mremap support and TLB optimization
References: <patchbomb.1312649882@localhost> <10a29e95223e52e49a61.1312649885@localhost>
In-Reply-To: <10a29e95223e52e49a61.1312649885@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>

On 08/06/2011 12:58 PM, aarcange@redhat.com wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> This adds THP support to mremap (decreases the number of split_huge_page
> called).
>
> Here are also some benchmarks with a proggy like this:

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
