Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 875046B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 18:21:05 -0400 (EDT)
Date: Wed, 12 Jun 2013 15:21:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4 v4]swap: change block allocation algorithm for SSD
Message-Id: <20130612152103.e929320315c4bf9d82fe33d5@linux-foundation.org>
In-Reply-To: <20130326053706.GA19646@kernel.org>
References: <20130326053706.GA19646@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Tue, 26 Mar 2013 13:37:06 +0800 Shaohua Li <shli@kernel.org> wrote:

> I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
> CPU time (when cluster is hard to find, the CPU time can be up to 80%), which
> becomes a bottleneck.  scan_swap_map() scans a byte array to search a 256 page
> cluster, which is very slow.
> 
> Here I introduced a simple algorithm to search cluster.

I had a few comments on the patches.

Problem is, I'm still stuck on
http://ozlabs.org/~akpm/mmots/broken-out/swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch.
I quite dislike that patch - it has to have more magic handwavy
constants per square inch than any patch I've ever seen before.

I'd really prefer that we come up with something more robust, adaptive
and generally thought-through than this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
