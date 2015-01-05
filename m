Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 47A736B0032
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 21:33:56 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so27213347pdj.20
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 18:33:56 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id v1si81139600pdp.252.2015.01.04.18.33.53
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 18:33:55 -0800 (PST)
Date: Mon, 5 Jan 2015 11:33:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] mm/compaction: enhance trace output to know more
 about compaction internals
Message-ID: <20150105023352.GB3534@js1304-P5Q-DELUXE>
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 03, 2014 at 04:52:05PM +0900, Joonsoo Kim wrote:
> It'd be useful to know where the both scanner is start. And, it also be
> useful to know current range where compaction work. It will help to find
> odd behaviour or problem on compaction.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello, Andrew and Vlastimil.

Could you review or merge this patchset?
It would help to trace compaction behaviour.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
