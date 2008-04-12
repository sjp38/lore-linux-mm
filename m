Subject: Re: [PATCH][-mm][1/2] core of page reclaim throttle
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080330171224.89D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080330171152.89D5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080330171224.89D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Sat, 12 Apr 2008 21:30:23 +0200
Message-Id: <1208028623.6230.67.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-03-30 at 17:15 +0900, KOSAKI Motohiro wrote:

> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h	2008-03-27 13:35:03.000000000 +0900
> +++ b/include/linux/mmzone.h	2008-03-27 15:55:50.000000000 +0900
> @@ -335,6 +335,8 @@ struct zone {
>  	unsigned long		spanned_pages;	/* total size, including holes */
>  	unsigned long		present_pages;	/* amount of memory (excluding holes) */
>  
> +	atomic_t		nr_reclaimers;
> +	wait_queue_head_t	reclaim_throttle_waitq;
>  	/*
>  	 * rarely used fields:

I'm thinking this ought to be a plist based wait_queue to avoid priority
inversions - but I don't think we have such a creature. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
