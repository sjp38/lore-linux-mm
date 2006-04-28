Date: Fri, 28 Apr 2006 11:10:16 +0200
From: Pavel Machek <pavel@suse.cz>
Subject: Re: Lockless page cache test results
Message-ID: <20060428091006.GA12001@elf.ucw.cz>
References: <20060426135310.GB5083@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060426135310.GB5083@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On St 26-04-06 15:53:10, Jens Axboe wrote:
> Hi,
> 
> Running a splice benchmark on a 4-way IPF box, I decided to give the
> lockless page cache patches from Nick a spin. I've attached the results
> as a png, it pretty much speaks for itself.
> 
> The test in question splices a 1GiB file to a pipe and then splices that
> to some output. Normally that output would be something interesting, in
> this case it's simply /dev/null. So it tests the input side of things
> only, which is what I wanted to do here. To get adequate runtime, the
> operation is repeated a number of times (120 in this example). The
> benchmark does that number of loops with 1, 2, 3, and 4 clients each
> pinned to a private CPU. The pinning is mainly done for more stable
> results.

35GB/sec, AFAICS? Not sure how significant this benchmark is.. even
with 4 clients, you have 2.5GB/sec, and that is better than almost
anything you can splice to...
								Pavel
-- 
Thanks for all the (sleeping) penguins.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
