Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A2F826B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 03:40:51 -0400 (EDT)
Date: Mon, 5 Aug 2013 16:41:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/4] mm, migrate: allocation new page lazyily in
 unmap_and_move()
Message-ID: <20130805074100.GE27240@lge.com>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375409279-16919-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20130802194102.GV715@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130802194102.GV715@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

> get_new_page() sets up result to communicate error codes from the
> following checks.  While the existing ones (page freed and thp split
> failed) don't change rc, somebody else might add a condition whose
> error code should be propagated back into *result but miss it.
> 
> Please leave get_new_page() where it is.  The win from this change is
> not big enough to risk these problems.

Hello, Johannes.

Okay. You are right. I will omit this patch next time.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
