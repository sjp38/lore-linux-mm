Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 91CDE6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 17:39:44 -0400 (EDT)
Date: Wed, 5 Jun 2013 18:39:34 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 2/7] mm: compaction: scan all memory with
 /proc/sys/vm/compact_memory
Message-ID: <20130605213933.GD19617@optiplex.redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370445037-24144-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>

On Wed, Jun 05, 2013 at 05:10:32PM +0200, Andrea Arcangeli wrote:
> Reset the stats so /proc/sys/vm/compact_memory will scan all memory.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/compaction.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>

Acked-by: Rafael Aquini <aquini@redhat.com>

 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 05ccb4c..cac9594 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1136,12 +1136,14 @@ void compact_pgdat(pg_data_t *pgdat, int order)
>  
>  static void compact_node(int nid)
>  {
> +	pg_data_t *pgdat = NODE_DATA(nid);
>  	struct compact_control cc = {
>  		.order = -1,
>  		.sync = true,
>  	};
>  
> -	__compact_pgdat(NODE_DATA(nid), &cc);
> +	reset_isolation_suitable(pgdat);
> +	__compact_pgdat(pgdat, &cc);
>  }
>  
>  /* Compact all nodes in the system */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
