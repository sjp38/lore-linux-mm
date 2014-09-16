Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 750C56B003C
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 22:40:56 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so7638541pde.12
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 19:40:56 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id e3si26703476pdf.48.2014.09.15.19.40.54
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 19:40:55 -0700 (PDT)
Date: Tue, 16 Sep 2014 11:41:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: simplify init_zspage free obj linking
Message-ID: <20140916024107.GF10912@bbox>
References: <20140914232427.GD2160@bbox>
 <1410814730-5740-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1410814730-5740-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Sep 15, 2014 at 04:58:50PM -0400, Dan Streetman wrote:
> Change zsmalloc init_zspage() logic to iterate through each object on
> each of its pages, checking the offset to verify the object is on the
> current page before linking it into the zspage.
> 
> The current zsmalloc init_zspage free object linking code has logic
> that relies on there only being one page per zspage when PAGE_SIZE
> is a multiple of class->size.  It calculates the number of objects
> for the current page, and iterates through all of them plus one,
> to account for the assumed partial object at the end of the page.
> While this currently works, the logic can be simplified to just
> link the object at each successive offset until the offset is larger
> than PAGE_SIZE, which does not rely on PAGE_SIZE being a multiple of
> class->size.
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
