Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E2C1F900146
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 20:15:00 -0400 (EDT)
Message-ID: <4E431EE7.5070306@redhat.com>
Date: Wed, 10 Aug 2011 20:14:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 3] mremap: check for overflow using deltas
References: <patchbomb.1312649882@localhost> <d244e0b6060fdeac2ab6.1312649883@localhost>
In-Reply-To: <d244e0b6060fdeac2ab6.1312649883@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>

On 08/06/2011 12:58 PM, aarcange@redhat.com wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Using "- 1" relies on the old_end to be page aligned and PAGE_SIZE>  1, those
> are reasonable requirements but the check remains obscure and it looks more
> like an off by one error than an overflow check. This I feel will improve
> readibility.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
