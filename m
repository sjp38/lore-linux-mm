Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4EB6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 06:32:06 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so13628935wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 03:32:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dv8si3725736wib.80.2015.09.25.03.32.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 03:32:05 -0700 (PDT)
Subject: Re: [PATCH v2 5/9] mm/compaction: allow to scan nonmovable pageblock
 when depleted state
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560522A2.50609@suse.cz>
Date: Fri, 25 Sep 2015 12:32:02 +0200
MIME-Version: 1.0
In-Reply-To: <1440382773-16070-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/24/2015 04:19 AM, Joonsoo Kim wrote:

[...]

> 
> Because we just allow freepage scanner to scan non-movable pageblock
> in very limited situation, more scanning events happen. But, allowing
> in very limited situation results in a very important benefit that
> memory isn't fragmented more than before. Fragmentation effect is
> measured on following patch so please refer it.

AFAICS it's measured only for the whole series in the cover letter, no? Just to
be sure I didn't overlook something.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/mmzone.h |  1 +
>  mm/compaction.c        | 27 +++++++++++++++++++++++++--
>  2 files changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e13b732..5cae0ad 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -545,6 +545,7 @@ enum zone_flags {
>  					 */
>  	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
>  	ZONE_COMPACTION_DEPLETED,	/* compaction possiblity depleted */
> +	ZONE_COMPACTION_SCANALLFREE,	/* scan all kinds of pageblocks */

"SCANALLFREE" is hard to read. Otherwise yeah, I agree scanning unmovable
pageblocks is necessary sometimes, and this seems to make a reasonable tradeoff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
