Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBB06B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 01:53:08 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so84127059pad.1
        for <linux-mm@kvack.org>; Sun, 06 Sep 2015 22:53:08 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ux5si18165196pbc.212.2015.09.06.22.53.06
        for <linux-mm@kvack.org>;
        Sun, 06 Sep 2015 22:53:07 -0700 (PDT)
Date: Mon, 7 Sep 2015 14:53:06 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] mm, compaction: disginguish contended status in
 tracepoint
Message-ID: <20150907055306.GD21207@js1304-P5Q-DELUXE>
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
 <1440689044-2922-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440689044-2922-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On Thu, Aug 27, 2015 at 05:24:04PM +0200, Vlastimil Babka wrote:
> Compaction returns prematurely with COMPACT_PARTIAL when contended or has fatal
> signal pending. This is ok for the callers, but might be misleading in the
> traces, as the usual reason to return COMPACT_PARTIAL is that we think the
> allocation should succeed. This patch distinguishes the premature ending
> condition. Further distinguishing the exact reason seems unnecessary for now.

isolate_migratepages() could return ISOLATE_ABORT and skip to call
compact_finished(). trace_mm_compaction_end() will print
COMPACT_PARTIAL in this case and we cannot distinguish premature
ending condition. Is it okay?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
