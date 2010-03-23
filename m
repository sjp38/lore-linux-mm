Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B20E66B01BC
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:27:01 -0400 (EDT)
Date: Tue, 23 Mar 2010 13:25:47 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 08/11] Add /proc trigger for memory compaction
In-Reply-To: <1269347146-7461-9-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003231323410.10178@router.home>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010, Mel Gorman wrote:

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0d2e8aa..faa9b53 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -346,3 +347,63 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  	return ret;
>  }
>
> +/* Compact all zones within a node */
> +static int compact_node(int nid)
> +{
> +	int zoneid;
> +	pg_data_t *pgdat;
> +	struct zone *zone;
> +
> +	if (nid < 0 || nid > nr_node_ids || !node_online(nid))

Must be nid >= nr_node_ids.

Otherwise

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
