Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 8204A6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 15:02:49 -0400 (EDT)
Date: Tue, 1 May 2012 12:02:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/5] mm + fs: prepare for non-page entries in page cache
Message-Id: <20120501120246.83d2ce28.akpm@linux-foundation.org>
In-Reply-To: <1335861713-4573-3-git-send-email-hannes@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
	<1335861713-4573-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue,  1 May 2012 10:41:50 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -544,8 +544,7 @@ static void evict(struct inode *inode)
>  	if (op->evict_inode) {
>  		op->evict_inode(inode);
>  	} else {
> -		if (inode->i_data.nrpages)
> -			truncate_inode_pages(&inode->i_data, 0);
> +		truncate_inode_pages(&inode->i_data, 0);

Why did we lose this optimisation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
