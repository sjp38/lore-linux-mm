Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6FD90013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 06:48:39 -0400 (EDT)
Date: Wed, 10 Aug 2011 11:48:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1 of 3] mremap: check for overflow using deltas
Message-ID: <20110810104834.GM9211@csn.ul.ie>
References: <patchbomb.1312649882@localhost>
 <d244e0b6060fdeac2ab6.1312649883@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <d244e0b6060fdeac2ab6.1312649883@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Aug 06, 2011 at 06:58:03PM +0200, aarcange@redhat.com wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Using "- 1" relies on the old_end to be page aligned and PAGE_SIZE > 1, those
> are reasonable requirements but the check remains obscure and it looks more
> like an off by one error than an overflow check. This I feel will improve
> readibility.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
