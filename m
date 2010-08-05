Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A7A9160020C
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 11:20:05 -0400 (EDT)
Message-ID: <4C5AD686.9040503@redhat.com>
Date: Thu, 05 Aug 2010 11:19:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151125.31BA.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100805151125.31BA.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On 08/05/2010 02:12 AM, KOSAKI Motohiro wrote:
> From: Wu Fengguang<fengguang.wu@intel.com>
>
> Fix "system goes unresponsive under memory pressure and lots of
> dirty/writeback pages" bug.
>
> 	http://lkml.org/lkml/2010/4/4/86
>
> In the above thread, Andreas Mohr described that
>
> 	Invoking any command locked up for minutes (note that I'm
> 	talking about attempted additional I/O to the _other_,
> 	_unaffected_ main system HDD - such as loading some shell
> 	binaries -, NOT the external SSD18M!!).
>
> This happens when the two conditions are both meet:
> - under memory pressure
> - writing heavily to a slow device

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
