Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B78476B002B
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 10:48:34 -0400 (EDT)
Date: Fri, 7 Sep 2012 10:37:51 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
Message-ID: <20120907143751.GB4670@phenom.dumpdata.com>
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <e33a2c0e-3b51-4d89-a2b2-c1ed9c8f862c@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e33a2c0e-3b51-4d89-a2b2-c1ed9c8f862c@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> significant design challenges exist, many of which are already resolved in
> the new codebase ("zcache2").  These design issues include:
.. snip..
> Before other key mm maintainers read and comment on zcache, I think
> it would be most wise to move to a codebase which resolves the known design
> problems or, at least to thoroughly discuss and debunk the design issues
> described above.  OR... it may be possible to identify and pursue some
> compromise plan.  In any case, I believe the promotion proposal is premature.

Thank you for the feedback!

I took your comments and pasted them in this patch.

Seth, Robert, Minchan, Nitin, can you guys provide some comments pls,
so we can put them as a TODO pls or modify the patch below.

Oh, I think I forgot Andrew's comment which was:

 - Explain which workloads this benefits and provide some benchmark data.
   This should help in narrowing down in which case we know zcache works
   well and in which it does not.

My TODO's were:

 - Figure out (this could be - and perhaps should be in frontswap) a
   determination whether this swap is quite fast and the CPU is slow
   (or taxed quite heavily now), so as to not slow the currently executing
   workloads.
 - Work out automatic benchmarks in three categories: database (I am going to use
   swing for that), compile (that one is easy), and firefox tab browsers
   overloading.
