Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 625126B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 17:40:52 -0500 (EST)
Message-ID: <4B86FC51.80903@redhat.com>
Date: Thu, 25 Feb 2010 17:40:17 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/15] readahead: add /debug/readahead/stats
References: <20100224031001.026464755@intel.com> <20100224031055.024165020@intel.com>
In-Reply-To: <20100224031055.024165020@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Chris Mason <chris.mason@oracle.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 02/23/2010 10:10 PM, Wu Fengguang wrote:
> Collect readahead stats when CONFIG_READAHEAD_STATS=y.
>
> This is enabled by default because the added overheads are trivial:
> two readahead_stats() calls per readahead.
>
> Example output:
> (taken from a fresh booted NFS-ROOT box with rsize=16k)
>
> $ cat /debug/readahead/stats
> pattern     readahead    eof_hit  cache_hit         io    sync_io    mmap_io       size async_size    io_size
> initial           524        216         26        498        498         18          7          4          4
> subsequent        181         80          1        130         13         60         25         25         24
> context            94         28          3         85         64          8          7          2          5
> thrash              0          0          0          0          0          0          0          0          0
> around            162        121         33        162        162        162         60          0         21
> fadvise             0          0          0          0          0          0          0          0          0
> random            137          0          0        137        137          0          1          0          1
> all              1098        445         63       1012        874          0         17          6          9
>
> The two most important columns are
> - io		number of readahead IO
> - io_size	average readahead IO size
>
> CC: Ingo Molnar<mingo@elte.hu>
> CC: Jens Axboe<jens.axboe@oracle.com>
> CC: Peter Zijlstra<a.p.zijlstra@chello.nl>
> Signed-off-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
