Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 32B216B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 12:52:04 -0500 (EST)
Message-ID: <4AEDCAA6.8050301@redhat.com>
Date: Sun, 01 Nov 2009 12:51:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2 3/5] vmscan: Stop zone_reclaim()'s wrong swap_cluster_max
 usage
References: <20091101234614.F401.A69D9226@jp.fujitsu.com> <20091102000951.F407.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091102000951.F407.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 11/01/2009 10:11 AM, KOSAKI Motohiro wrote:
> In old days, we didn't have sc.nr_to_reclaim and it brought
> sc.swap_cluster_max misuse.
>
> huge sc.swap_cluster_max might makes unnecessary OOM and
> no performance benefit.
>
> Now, we can remove above dangerous one.
>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
