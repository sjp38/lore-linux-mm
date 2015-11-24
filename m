Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 280636B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 10:36:11 -0500 (EST)
Received: by iofh3 with SMTP id h3so23743654iof.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:36:11 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id x74si14157356ioi.194.2015.11.24.07.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 07:36:10 -0800 (PST)
Date: Tue, 24 Nov 2015 09:36:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
In-Reply-To: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue, 24 Nov 2015, Joonsoo Kim wrote:

> When I tested compaction in low memory condition, I found that
> my benchmark is stuck in congestion_wait() at shrink_inactive_list().
> This stuck last for 1 sec and after then it can escape. More investigation
> shows that it is due to stale vmstat value. vmstat is updated every 1 sec
> so it is stuck for 1 sec.

vmstat values are not designed to be accurate and are not guaranteed to be
accurate. Comparing to specific values should not be done. If you need an
accurate counter then please use another method of accounting like an
atomic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
