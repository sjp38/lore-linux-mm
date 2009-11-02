Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D5C1B6B006A
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 19:42:49 -0500 (EST)
Received: by yxe10 with SMTP id 10so4471367yxe.12
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 16:42:48 -0800 (PST)
Date: Mon, 2 Nov 2009 09:40:12 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCHv2 3/5] vmscan: Stop zone_reclaim()'s wrong
 swap_cluster_max usage
Message-Id: <20091102094012.8a8fc5c8.minchan.kim@barrios-desktop>
In-Reply-To: <20091102000951.F407.A69D9226@jp.fujitsu.com>
References: <20091101234614.F401.A69D9226@jp.fujitsu.com>
	<20091102000951.F407.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009 00:11:02 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> In old days, we didn't have sc.nr_to_reclaim and it brought
> sc.swap_cluster_max misuse.
> 
> huge sc.swap_cluster_max might makes unnecessary OOM and
> no performance benefit.
> 
> Now, we can remove above dangerous one.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
