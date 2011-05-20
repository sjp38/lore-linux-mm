Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 232048D003B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 15:23:09 -0400 (EDT)
Message-ID: <4DD6BF94.7000902@fusionio.com>
Date: Fri, 20 May 2011 21:23:00 +0200
From: Jens Axboe <jaxboe@fusionio.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] mm: Kill set but not used var in  bdi_debug_stats_show()
References: <1305918786-7239-1-git-send-email-padovan@profusion.mobi>
In-Reply-To: <1305918786-7239-1-git-send-email-padovan@profusion.mobi>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gustavo F. Padovan" <padovan@profusion.mobi>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <dchinner@redhat.com>, MEMORY MANAGEMENT <linux-mm@kvack.org>

On 2011-05-20 21:12, Gustavo F. Padovan wrote:
> Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
> ---
>  mm/backing-dev.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index befc875..f032e6e 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -63,10 +63,10 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>  	unsigned long background_thresh;
>  	unsigned long dirty_thresh;
>  	unsigned long bdi_thresh;
> -	unsigned long nr_dirty, nr_io, nr_more_io, nr_wb;
> +	unsigned long nr_dirty, nr_io, nr_more_io;
>  	struct inode *inode;
>  
> -	nr_wb = nr_dirty = nr_io = nr_more_io = 0;
> +	nr_dirty = nr_io = nr_more_io = 0;
>  	spin_lock(&inode_wb_list_lock);
>  	list_for_each_entry(inode, &wb->b_dirty, i_wb_list)
>  		nr_dirty++;

Good catch, nr_wb should have been killed with the removal of the worker
list. I'll queue this up.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
