Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFEF0680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:35:05 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so8860200wmi.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:35:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k4si1766850wmf.93.2017.02.14.08.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 08:35:04 -0800 (PST)
Date: Tue, 14 Feb 2017 11:34:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 02/10] mm, compaction: remove redundant watermark
 check in compact_finished()
Message-ID: <20170214163453.GC2450@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:35PM +0100, Vlastimil Babka wrote:
> When detecting whether compaction has succeeded in forming a high-order page,
> __compact_finished() employs a watermark check, followed by an own search for
> a suitable page in the freelists. This is not ideal for two reasons:
> 
> - The watermark check also searches high-order freelists, but has a less strict
>   criteria wrt fallback. It's therefore redundant and waste of cycles. This was
>   different in the past when high-order watermark check attempted to apply
>   reserves to high-order pages.
> 
> - The watermark check might actually fail due to lack of order-0 pages.
>   Compaction can't help with that, so there's no point in continuing because of
>   that. It's possible that high-order page still exists and it terminates.
> 
> This patch therefore removes the watermark check. This should save some cycles
> and terminate compaction sooner in some cases.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
