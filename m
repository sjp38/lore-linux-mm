Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCD2828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:19:16 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id u190so14575578pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:19:16 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id u26si2713267pfi.15.2016.03.14.23.19.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 23:19:15 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id n5so14610220pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:19:15 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:20:38 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 07/19] zsmalloc: reordering function parameter
Message-ID: <20160315062038.GC1464@swordfish>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-8-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457681423-26664-8-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On (03/11/16 16:30), Minchan Kim wrote:
> This patch cleans up function parameter ordering to order
> higher data structure first.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
