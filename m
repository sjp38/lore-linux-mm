Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5D30D6B0038
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 08:32:54 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so6866395wes.4
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 05:32:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p4si14874959wib.95.2014.09.02.05.32.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Sep 2014 05:32:53 -0700 (PDT)
Date: Tue, 2 Sep 2014 08:32:40 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 3/6] mm/balloon_compaction: isolate balloon pages
 without lru_lock
Message-ID: <20140902123239.GD14419@t510.redhat.com>
References: <20140830163834.29066.98205.stgit@zurg>
 <20140830164117.29066.18189.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140830164117.29066.18189.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, Aug 30, 2014 at 08:41:17PM +0400, Konstantin Khlebnikov wrote:
> From: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> 
> LRU-lock isn't required for balloon page isolation. This check makes migration
> of some ballooned pages mostly impossible because isolate_migratepages_range()
> drops LRU lock periodically.
> 
> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Cc: stable <stable@vger.kernel.org> # v3.8
> ---
>  mm/compaction.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 73466e1..ad58f73 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -643,7 +643,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
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
