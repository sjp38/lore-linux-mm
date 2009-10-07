Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 97F3A6B004F
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 15:33:11 -0400 (EDT)
Message-ID: <4ACCECD4.1050509@redhat.com>
Date: Wed, 07 Oct 2009 15:32:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: order evictable rescue in LRU putback
References: <1254940610-27324-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1254940610-27324-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:

> This patch adds an explicit full barrier to force ordering between
> SetPageLRU() and PageMlocked() so that either one of the competitors
> rescues the page.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
