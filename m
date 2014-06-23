Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8E56B0035
	for <linux-mm@kvack.org>; Sun, 22 Jun 2014 23:05:18 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so5116668pdj.33
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 20:05:18 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id qg1si19893474pac.75.2014.06.22.20.05.16
        for <linux-mm@kvack.org>;
        Sun, 22 Jun 2014 20:05:17 -0700 (PDT)
Date: Mon, 23 Jun 2014 12:06:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 11/13] mm, compaction: pass gfp mask to compact_control
Message-ID: <20140623030605.GF12413@bbox>
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz>
 <1403279383-5862-12-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1403279383-5862-12-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On Fri, Jun 20, 2014 at 05:49:41PM +0200, Vlastimil Babka wrote:
> From: David Rientjes <rientjes@google.com>
> 
> struct compact_control currently converts the gfp mask to a migratetype, but we
> need the entire gfp mask in a follow-up patch.
> 
> Pass the entire gfp mask as part of struct compact_control.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
