Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id A0F6C6B0035
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 19:35:16 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id j7so7740786qaq.28
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 16:35:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e15si36385051qaw.109.2014.08.20.16.35.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 16:35:16 -0700 (PDT)
Date: Wed, 20 Aug 2014 20:35:06 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 3/7] mm/balloon_compaction: isolate balloon pages without
 lru_lock
Message-ID: <20140820233505.GD3457@optiplex.redhat.com>
References: <20140820150435.4194.28003.stgit@buzz>
 <20140820150446.4194.5716.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140820150446.4194.5716.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

On Wed, Aug 20, 2014 at 07:04:46PM +0400, Konstantin Khlebnikov wrote:
> LRU-lock isn't required for balloon page isolation. This check makes migration
> of some ballooned pages mostly impossible because isolate_migratepages_range()
> drops LRU lock periodically.
>
just for historical/explanatory purposes: https://lkml.org/lkml/2013/12/6/183 

> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Cc: stable <stable@vger.kernel.org> # v3.8
> ---
>  mm/compaction.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 21bf292..0653f5f 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -597,7 +597,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>  		 */
>  		if (!PageLRU(page)) {
>  			if (unlikely(balloon_page_movable(page))) {
> -				if (locked && balloon_page_isolate(page)) {
> +				if (balloon_page_isolate(page)) {
>  					/* Successfully isolated */
>  					goto isolate_success;
>  				}
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
