Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id CC5546B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 08:57:13 -0400 (EDT)
Message-ID: <503B6E9C.50904@redhat.com>
Date: Mon, 27 Aug 2012 08:57:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch v2]swap: add a simple random read swapin detection
References: <20120827040037.GA8062@kernel.org>
In-Reply-To: <20120827040037.GA8062@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, fengguang.wu@intel.com, minchan@kernel.org

On 08/27/2012 12:00 AM, Shaohua Li wrote:
> The swapin readahead does a blind readahead regardless if the swapin is
> sequential. This is ok for harddisk and random read, because read big size has
> no penality in harddisk, and if the readahead pages are garbage, they can be
> reclaimed fastly. But for SSD, big size read is more expensive than small size
> read. If readahead pages are garbage, such readahead only has overhead.
>
> This patch addes a simple random read detection like what file mmap readahead
> does. If random read is detected, swapin readahead will be skipped. This
> improves a lot for a swap workload with random IO in a fast SSD.
>
> I run anonymous mmap write micro benchmark, which will triger swapin/swapout.
> 			runtime changes with path
> randwrite harddisk	-38.7%
> seqwrite harddisk	-1.1%
> randwrite SSD		-46.9%
> seqwrite SSD		+0.3%
>
> For both harddisk and SSD, the randwrite swap workload run time is reduced
> significant. sequential write swap workload hasn't chanage.

Very nice results!

> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
