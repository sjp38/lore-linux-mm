Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id A0B656B0002
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 21:04:32 -0500 (EST)
Date: Mon, 18 Feb 2013 11:04:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [LSF/MM TOPIC][ATTEND] Volatile Ranges
Message-ID: <20130218020429.GA7931@blaptop>
References: <511EA29C.3030301@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <511EA29C.3030301@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

Hi John,

On Fri, Feb 15, 2013 at 01:03:24PM -0800, John Stultz wrote:
> Sorry for being late here.
> 
> I wanted to propose some further discussion on the volatile ranges concept.
> 
> Basically trying to sort out a coherent story around:
> 
> * My attempts at volatile ranges for shared tmpfs files (similar
> functionality as Android's ashmem provides)
> 
> * Minchan's volatile ranges for anonymous memory
> 

FYI,
I have a plan to redesign anon volatile range by some reasons.
In old version, I have been working with Jason who is jemalloc author
and he has a very interested in anon volatile.

I saw 2x faster with certain webserver workload with jemalloc which is
tweaked by Jason and me. Even, I have a plan to enhance it much higher.
If this topic is selected and I will be there,
I will share it with pleasure.

Thanks.


> * How to track page volatility & purged state (via VMAs vs file
> address_space)
> 
> * Purged data semantics (ie: Mozilla's request for SIGBUS on purged
> data access vs zero fill)
> 
> * Aging anonymous pages in swapless systems
> 
> thanks
> -john
> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
