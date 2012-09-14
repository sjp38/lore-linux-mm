Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 95C836B018B
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 19:58:17 -0400 (EDT)
Date: Fri, 14 Sep 2012 09:00:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] enable CONFIG_COMPACTION by default
Message-ID: <20120914000028.GC5085@bbox>
References: <20120913162104.1458bea2@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913162104.1458bea2@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

Hi Rik,

On Thu, Sep 13, 2012 at 04:21:04PM -0400, Rik van Riel wrote:
> Now that lumpy reclaim has been removed, compaction is the
> only way left to free up contiguous memory areas. It is time
> to just enable CONFIG_COMPACTION by default.
>     
> Signed-off-by: Rik van Riel <riel@redhat.com>

I tried this a few month ago and Mel had a concern on size
bloating (compaction.o + migration.o) where system doesn't
use higher order allocation.

Now that I think about it, admin should configure carefully
and manually if he has a size concern of vmlinux without
depending auto-generating config.
So I really want this.

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
