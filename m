Date: Thu, 24 Jul 2008 15:26:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mm] vmscan: fix swapout on sequential IO
In-Reply-To: <20080723144115.72803eb8@bree.surriel.com>
References: <20080723144115.72803eb8@bree.surriel.com>
Message-Id: <20080724152555.869D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@saeurebad.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> -			zone->lru[l].nr_scan += scan + 1;
> +			zone->lru[l].nr_scan += scan + force_scan;
>  			nr[l] = zone->lru[l].nr_scan;
>  			if (nr[l] >= sc->swap_cluster_max)
>  				zone->lru[l].nr_scan = 0;

looks good to me.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
