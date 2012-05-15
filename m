Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id CF9566B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 14:24:23 -0400 (EDT)
Message-ID: <4FB29F51.8060605@kernel.dk>
Date: Tue, 15 May 2012 20:24:17 +0200
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] swap: improve swap I/O rate
References: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
In-Reply-To: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ehrhardt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org

On 2012-05-14 13:58, ehrhardt@linux.vnet.ibm.com wrote:
> From: Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>
> 
> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> 
> In an memory overcommitment scneario with KVM I ran into a lot of wiats for
> swap. While checking the I/O done on the swap disks I found almost all I/Os
> to be done as single page 4k request. Despite the fact that swap in is a
> batch of 1<<page-cluster pages as swap readahead and swap out is a list of
> pages written in shrink_page_list.
> 
> [1/2 swap in improvment]
> The read patch shows improvements of up to 50% swap throughput, much happier
> guest systems and even when running with comparable throughput a lot I/O per
> seconds saved leaving resources in the SAN for other consumers.
> 
> [2/2 documentation]
> While doing so I also realized that the documentation for
> proc/sys/vm/page-cluster is no more matching the code
> 
> [missing patch #3]
> I tried to get a similar patch working for swap out in shrink_page_list. And
> it worked in functional terms, but the additional mergin was negligible.
> Maybe the cond_resched triggers much mor often than I expected, I'm open for
> suggestions regarding improving the pagout I/O sizes as well.
> 
> Kind regards,
> Christian Ehrhardt
> 
> 
> Christian Ehrhardt (2):
>   swap: allow swap readahead to be merged
>   documentation: update how page-cluster affects swap I/O

Looks good to me, you can add my acked-by to both of them.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
