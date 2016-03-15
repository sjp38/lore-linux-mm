Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id E0760828DF
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 02:20:29 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id u190so14619652pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:20:29 -0700 (PDT)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id m65si17317607pfi.168.2016.03.14.23.20.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 23:20:29 -0700 (PDT)
Received: by mail-pf0-x233.google.com with SMTP id n5so14654580pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 23:20:29 -0700 (PDT)
Date: Tue, 15 Mar 2016 15:21:52 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 08/19] zsmalloc: remove unused pool param in obj_free
Message-ID: <20160315062152.GD1464@swordfish>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
 <1457681423-26664-9-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457681423-26664-9-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>

On (03/11/16 16:30), Minchan Kim wrote:
> Let's remove unused pool param in obj_free
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
