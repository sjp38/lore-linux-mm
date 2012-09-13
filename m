Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 79CE16B0189
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 19:13:42 -0400 (EDT)
Date: Thu, 13 Sep 2012 19:13:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm] enable CONFIG_COMPACTION by default
Message-ID: <20120913231335.GA1569@cmpxchg.org>
References: <20120913162104.1458bea2@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913162104.1458bea2@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 13, 2012 at 04:21:04PM -0400, Rik van Riel wrote:
> Now that lumpy reclaim has been removed, compaction is the
> only way left to free up contiguous memory areas. It is time
> to just enable CONFIG_COMPACTION by default.
>     
> Signed-off-by: Rik van Riel <riel@redhat.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
