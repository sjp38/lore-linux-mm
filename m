Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id D4B7B6B00B2
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 11:49:56 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so5703935pbb.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 08:49:56 -0700 (PDT)
Date: Tue, 16 Oct 2012 00:49:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: use IS_ENABLED(CONFIG_COMPACTION) instead of
 COMPACTION_BUILD
Message-ID: <20121015154952.GB2840@barrios>
References: <1350302735-8416-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1350302735-8416-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, Oct 15, 2012 at 03:05:35PM +0300, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> We don't need custom COMPACTION_BUILD anymore, since we have handy
> IS_ENABLED().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
