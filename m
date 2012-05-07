Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id E22DE6B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 17:32:20 -0400 (EDT)
Date: Mon, 7 May 2012 14:32:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: nobootmem: fix sign extend problem in
 __free_pages_memory()
Message-Id: <20120507143218.e8cc5584.akpm@linux-foundation.org>
In-Reply-To: <20120507193202.GA11518@sgi.com>
References: <20120507193202.GA11518@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, David Miller <davem@davemloft.net>

On Mon, 7 May 2012 14:32:03 -0500
Russ Anderson <rja@sgi.com> wrote:

> Systems with 8 TBytes of memory or greater can hit a problem 
> where only the the first 8 TB of memory shows up.

erk.

>  This is
> due to "int i" being smaller than "unsigned long start_aligned",
> causing the high bits to be dropped.
> 
> The fix is to change i to unsigned long to match start_aligned
> and end_aligned.
> 
> Thanks to Jack Steiner (steiner@sgi.com) for assistance tracking
> this down.
> 

I added the Cc: <stable@vger.kernel.org> to this.  The fix is small and
safe and someone might want to run older kernels on such a machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
