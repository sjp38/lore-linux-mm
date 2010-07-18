Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0687D600365
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 02:01:13 -0400 (EDT)
Date: Sun, 18 Jul 2010 02:01:06 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan
 > 0
Message-ID: <20100718060106.GA579@infradead.org>
References: <4C425273.5000702@gmail.com>
 <4C427DC8.6020504@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C427DC8.6020504@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Eric Sandeen <sandeen@redhat.com>
Cc: Wang Sheng-Hui <crosslonelyover@gmail.com>, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>, a.gruenbacher@computer.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 17, 2010 at 11:06:32PM -0500, Eric Sandeen wrote:
> +	/* Count remaining entries */
> +	spin_lock(&mb_cache_spinlock);
> +	list_for_each(l, &mb_cache_list) {
> +		struct mb_cache *cache =
> +			list_entry(l, struct mb_cache, c_cache_list);

This should be using list_for_each_entry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
