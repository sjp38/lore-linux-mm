Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4EBF46B0134
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 20:26:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I0QH8w016246
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Oct 2010 09:26:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A9F7B45DE4E
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:26:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8982645DE4D
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:26:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 735D71DB8049
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:26:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 330BD1DB8041
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:26:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 11/16] mm: fixed typos
In-Reply-To: <1287235165-27841-11-git-send-email-andrea.gelmini@gelma.net>
References: <1287235165-27841-1-git-send-email-andrea.gelmini@gelma.net> <1287235165-27841-11-git-send-email-andrea.gelmini@gelma.net>
Message-Id: <20101018092415.3AD1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Oct 2010 09:26:16 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Gelmini <andrea.gelmini@gelma.net>
Cc: kosaki.motohiro@jp.fujitsu.com, gelma@gelma.net, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
> ---
>  mm/percpu.c |    2 +-
>  mm/vmscan.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index c76ef38..8b9aa45 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -31,7 +31,7 @@
>   * as small as 4 bytes.  The allocator organizes chunks into lists
>   * according to free size and tries to allocate from the fullest one.
>   * Each chunk keeps the maximum contiguous area size hint which is
> - * guaranteed to be eqaul to or larger than the maximum contiguous
> + * guaranteed to be equal to or larger than the maximum contiguous
>   * area in the chunk.  This helps the allocator not to iterate the
>   * chunk maps unnecessarily.
>   *
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c5dfabf..08823c4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -79,7 +79,7 @@ struct scan_control {
>  	int order;
>  
>  	/*
> -	 * Intend to reclaim enough contenious memory rather than to reclaim
> +	 * Intend to reclaim enough contiguous memory rather than to reclaim
>  	 * enough amount memory. I.e, it's the mode for high order allocation.
>  	 */
>  	bool lumpy_reclaim_mode;

Please cc lkml and linux-mm when you post any patch. (I've added them)
but anyway, this looks good.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
