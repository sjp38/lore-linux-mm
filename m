Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA6A6B002C
	for <linux-mm@kvack.org>; Sat,  8 Oct 2011 05:43:09 -0400 (EDT)
Received: by iaen33 with SMTP id n33so7887835iae.14
        for <linux-mm@kvack.org>; Sat, 08 Oct 2011 02:43:07 -0700 (PDT)
Date: Sat, 8 Oct 2011 18:43:00 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: mm: Do not drain pagevecs for mlockall(MCL_FUTURE)
Message-ID: <20111008094300.GB8679@barrios-desktop>
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
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
