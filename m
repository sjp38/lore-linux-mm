Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1A8066B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 11:17:19 -0400 (EDT)
Message-ID: <4C7FBFE6.7060600@redhat.com>
Date: Thu, 02 Sep 2010 11:16:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vmscan: prevent background aging of anon page in no
 swap system
References: <1283440333-14451-1-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1283440333-14451-1-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On 09/02/2010 11:12 AM, Minchan Kim wrote:

> +	/*
> +	 * If we don't have enough swap space, anonymous page deactivation
> +	 * is pointless.
> +	 */
> +	if (!nr_swap_pages)
> +		return 0;

It may be better to test !total_swap_pages and change the
comment to:

	/*
	 * If we don't have swap space, anonymous page deactivation
	 * is pointless.
	 */

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
