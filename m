Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 319BB6B00BB
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:37:55 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u56so891860wes.16
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:37:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dr11si9076331wid.3.2014.02.25.12.37.53
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 12:37:53 -0800 (PST)
Message-ID: <530CFF1B.8020901@redhat.com>
Date: Tue, 25 Feb 2014 15:37:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: fix GFP_THISNODE callers and clarify
References: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org> <1393360022-22566-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1393360022-22566-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Stancek <jstancek@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/25/2014 03:27 PM, Johannes Weiner wrote:
> GFP_THISNODE is for callers that implement their own clever fallback
> to remote nodes, and so no direct reclaim is invoked.  There are many
> current users that only want node exclusiveness but still want reclaim
> to make the allocation happen.  Convert them over to __GFP_THISNODE
> and update the documentation to clarify GFP_THISNODE semantics.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
