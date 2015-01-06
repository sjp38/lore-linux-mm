Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 052056B00BB
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 06:27:47 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so5873914wib.1
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 03:27:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si84173403wjr.16.2015.01.06.03.27.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 03:27:45 -0800 (PST)
Message-ID: <54ABC6AF.1020108@suse.cz>
Date: Tue, 06 Jan 2015 12:27:43 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm/compaction: add tracepoint to observe behaviour
 of compaction defer
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com> <1417593127-6819-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1417593127-6819-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/03/2014 08:52 AM, Joonsoo Kim wrote:
> compaction deferring logic is heavy hammer that block the way to
> the compaction. It doesn't consider overall system state, so it
> could prevent user from doing compaction falsely. In other words,
> even if system has enough range of memory to compact, compaction would be
> skipped due to compaction deferring logic. This patch add new tracepoint
> to understand work of deferring logic. This will also help to check
> compaction success and fail.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

You only call the tracepoints from try_to_compact_pages(), but the corresponding
functions are also called from elsewhere, e.g. kswapd. Shouldn't all be
included? Otherwise one might consider the trace as showing a bug, where the
defer state suddenly changed without being captured in the trace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
