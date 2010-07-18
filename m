Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3986007F3
	for <linux-mm@kvack.org>; Sun, 18 Jul 2010 04:27:31 -0400 (EDT)
Message-ID: <4C42BAE5.9020606@cs.helsinki.fi>
Date: Sun, 18 Jul 2010 11:27:17 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] Basic zcache functionality
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <1279283870-18549-3-git-send-email-ngupta@vflare.org>
In-Reply-To: <1279283870-18549-3-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nitin Gupta wrote:
> +static void zcache_add_stat(struct zcache_pool *zpool,
> +		enum zcache_pool_stats_index idx, s64 val)
> +{
> +	struct zcache_pool_stats_cpu *stats;
> +
> +	preempt_disable();
> +	stats = __this_cpu_ptr(zpool->stats);
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->count[idx] += val;
> +	u64_stats_update_end(&stats->syncp);
> +	preempt_enable();
> +
> +}

You should probably use this_cpu_inc() here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
