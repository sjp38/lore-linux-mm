Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 998506B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 08:57:29 -0500 (EST)
Date: Mon, 7 Jan 2013 13:57:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: fix echo 1 > compact_memory return error
 issue
Message-ID: <20130107135721.GD3885@suse.de>
References: <1357458273-28558-1-git-send-email-r64343@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1357458273-28558-1-git-send-email-r64343@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Liu <r64343@freescale.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Sun, Jan 06, 2013 at 03:44:33PM +0800, Jason Liu wrote:
> when run the folloing command under shell, it will return error
> sh/$ echo 1 > /proc/sys/vm/compact_memory
> sh/$ sh: write error: Bad address
> 
> After strace, I found the following log:
> ...
> write(1, "1\n", 2)               = 3
> write(1, "", 4294967295)         = -1 EFAULT (Bad address)
> write(2, "echo: write error: Bad address\n", 31echo: write error: Bad address
> ) = 31
> 
> This tells system return 3(COMPACT_COMPLETE) after write data to compact_memory.
> 
> The fix is to make the system just return 0 instead 3(COMPACT_COMPLETE) from
> sysctl_compaction_handler after compaction_nodes finished.
> 
> Suggested-by:David Rientjes <rientjes@google.com>
> Cc:Mel Gorman <mgorman@suse.de>
> Cc:Andrew Morton <akpm@linux-foundation.org>
> Cc:Rik van Riel <riel@redhat.com>
> Cc:Minchan Kim <minchan@kernel.org>
> Cc:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Jason Liu <r64343@freescale.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
