Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 96F718D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:45:11 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE5j9CE016023
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:45:09 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3204A45DE54
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:45:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C8FA645DE51
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:45:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ACFA5E38002
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:45:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 581A0E08002
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:45:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm,compaction: Add COMPACTION_BUILD
In-Reply-To: <1289502424-12661-3-git-send-email-mel@csn.ul.ie>
References: <1289502424-12661-1-git-send-email-mel@csn.ul.ie> <1289502424-12661-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20101114144413.E022.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 14:45:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> To avoid #ifdef COMPACTION in a following patch, this patch adds
> COMPACTION_BUILD that is similar to NUMA_BUILD in operation.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/kernel.h |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 450092c..c00c5d1 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -826,6 +826,13 @@ struct sysinfo {
>  #define NUMA_BUILD 0
>  #endif
>  
> +/* This helps us avoid #ifdef CONFIG_COMPACTION */
> +#ifdef CONFIG_COMPACTION
> +#define COMPACTION_BUILD 1
> +#else
> +#define COMPACTION_BUILD 0
> +#endif
> +

Looks good, of cource. but I think this patch can be fold [3/3] beucase 
it doesn't have any change.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
