Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3152A6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:22:27 -0500 (EST)
Received: by wmww144 with SMTP id w144so118848881wmw.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:22:26 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id e17si45935260wjr.24.2015.11.16.05.22.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 05:22:25 -0800 (PST)
Received: by wmww144 with SMTP id w144so118848118wmw.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 05:22:25 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH 0/2] get rid of __alloc_pages_high_priority
Date: Mon, 16 Nov 2015 14:22:17 +0100
Message-Id: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this has been posted http://lkml.kernel.org/r/1447343618-19696-1-git-send-email-mhocko%40kernel.org
last week. David has requested to split the patch into two parts
one to removed and opencode __alloc_pages_high_priority without
any functional changes and the other one which changes the retry
behavior for __GFP_NOFAIL with ALLOC_NO_WATERMARKS allocation context.
This was reflected in this submission.

The end result is very same so I've kept Mel's Acked-by. Let me know if
you do not agree with this Mel and I will drop it.

 mm/page_alloc.c | 48 +++++++++++++++++-------------------------------
 1 file changed, 17 insertions(+), 31 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
