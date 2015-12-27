Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3D35582F65
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 13:02:01 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p187so239442884wmp.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 10:02:01 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id y127si54363201wmg.107.2015.12.27.10.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 10:02:00 -0800 (PST)
Subject: Re: [PATCH trivial] lib+mm: fix few spelling mistakes
References: <1451224703-22358-1-git-send-email-jslaby@suse.cz>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <56802791.8060103@infradead.org>
Date: Sun, 27 Dec 2015 10:01:53 -0800
MIME-Version: 1.0
In-Reply-To: <1451224703-22358-1-git-send-email-jslaby@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>, trivial@kernel.org
Cc: linux-kernel@vger.kernel.org, Bogdan Sikora <bsikora@redhat.com>, linux-mm@kvack.org, Rafael Aquini <aquini@redhat.com>, Kent Overstreet <kmo@daterainc.com>, Jan Kara <jack@suse.cz>

On 12/27/15 05:58, Jiri Slaby wrote:
> From: Bogdan Sikora <bsikora@redhat.com>
> 
> All are in comments.
> 
> Signed-off-by: Bogdan Sikora <bsikora@redhat.com>
> Cc: <linux-mm@kvack.org>
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: Kent Overstreet <kmo@daterainc.com>
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> ---
>  lib/flex_proportions.c  | 2 +-
>  lib/percpu-refcount.c   | 2 +-
>  mm/balloon_compaction.c | 4 ++--
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 

> diff --git a/lib/percpu-refcount.c b/lib/percpu-refcount.c
> index 6111bcb28376..2c1f256fdc84 100644
> --- a/lib/percpu-refcount.c
> +++ b/lib/percpu-refcount.c
> @@ -12,7 +12,7 @@
>   * particular cpu can (and will) wrap - this is fine, when we go to shutdown the
>   * percpu counters will all sum to the correct value
>   *
> - * (More precisely: because moduler arithmatic is commutative the sum of all the
> + * (More precisely: because moduler arithmetic is commutative the sum of all the

                               modular

>   * percpu_count vars will be equal to what it would have been if all the gets
>   * and puts were done to a single integer, even if some of the percpu integers
>   * overflow or underflow).


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
