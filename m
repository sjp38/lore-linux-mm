Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8960A6B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 01:02:50 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bj10so16766463pad.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 22:02:50 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n17si40596574pfa.4.2016.02.28.22.02.49
        for <linux-mm@kvack.org>;
        Sun, 28 Feb 2016 22:02:49 -0800 (PST)
Date: Mon, 29 Feb 2016 15:02:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: add compact column to pool stat
Message-ID: <20160229060247.GA3382@bbox>
References: <1456554233-9088-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456554233-9088-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sat, Feb 27, 2016 at 03:23:53PM +0900, Sergey Senozhatsky wrote:
> Add a new column to pool stats, which will tell us class' zs_can_compact()
> number, so it will be easier to analyze zsmalloc fragmentation.

Just nitpick:

Strictly speaking, zs_can_compact number is number of "ideal freeable page
by compaction". How about using high level term in description rather than
function name?


> 
> At the moment, we have only numbers of FULL and ALMOST_EMPTY classes, but
> they don't tell us how badly the class is fragmented internally.
> 
> The new /sys/kernel/debug/zsmalloc/zramX/classes output look as follows:
> 
>  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage compact
> [..]
>     12   224           0            2           146          5          8                4       4
>     13   240           0            0             0          0          0                1       0
>     14   256           1           13          1840       1672        115                1      10
>     15   272           0            0             0          0          0                1       0
> [..]
>     49   816           0            3           745        735        149                1       2
>     51   848           3            4           361        306         76                4       8
>     52   864          12           14           378        268         81                3      21
>     54   896           1           12           117         57         26                2      12
>     57   944           0            0             0          0          0                3       0
> [..]
>  Total                26          131         12709      10994       1071                      134
> 
> For example, from this particular output we can easily conclude that class-896
> is heavily fragmented -- it occupies 26 pages, 12 can be freed by compaction.

How about using "freeable" or something which could represent "freeable"?
IMO, it's more strightforward for user.

Other than that,

Acked-by: Minchan Kim <minchan@kernel.org>


Thanks for the nice job!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
