Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CE40E6B0257
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:17:46 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id x3so14608256pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:17:46 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id 74si17568927pfk.37.2016.03.14.23.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 23:17:45 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id u190so14523126pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:17:45 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:19:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 05/19] zsmalloc: use first_page rather than page
Message-ID: <20160315061908.GA1464@swordfish>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-6-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457681423-26664-6-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On (03/11/16 16:30), Minchan Kim wrote:
> This patch cleans up function parameter "struct page".
> Many functions of zsmalloc expects that page paramter is "first_page"
> so use "first_page" rather than "page" for code readability.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
