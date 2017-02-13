Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 093646B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:49:42 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r141so40575331wmg.4
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:49:41 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id m139si5042225wma.32.2017.02.13.02.49.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 02:49:40 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id A1C6B1C163E
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:49:40 +0000 (GMT)
Date: Mon, 13 Feb 2017 10:49:40 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 02/10] mm, compaction: remove redundant watermark
 check in compact_finished()
Message-ID: <20170213104940.jifpc5g5m5bty7cx@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

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

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
