Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA406B002E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 10:58:21 -0400 (EDT)
Date: Wed, 12 Oct 2011 10:57:49 -0400
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: mm: Do not drain pagevecs for mlockall(MCL_FUTURE)
Message-ID: <20111012145748.GB6478@redhat.com>
References: <alpine.DEB.2.00.1110071529110.15540@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110071529110.15540@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

On Fri, Oct 07, 2011 at 03:32:13PM -0500, Christoph Lameter wrote:
> MCL_FUTURE does not move pages between lru list and draining the LRU per
> cpu pagevecs is a nasty activity. Avoid doing it unecessarily.
> 
> Signed-off-by: Christoph Lameter <cl@gentwo.org>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
