Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4C42D6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 04:20:38 -0400 (EDT)
Date: Mon, 8 Aug 2011 10:20:09 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH 1 of 3] mremap: check for overflow using deltas
Message-ID: <20110808082009.GA27011@redhat.com>
References: <patchbomb.1312649882@localhost>
 <d244e0b6060fdeac2ab6.1312649883@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d244e0b6060fdeac2ab6.1312649883@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Sat, Aug 06, 2011 at 06:58:03PM +0200, aarcange@redhat.com wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Using "- 1" relies on the old_end to be page aligned and PAGE_SIZE > 1, those
> are reasonable requirements but the check remains obscure and it looks more
> like an off by one error than an overflow check. This I feel will improve
> readibility.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
