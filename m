Message-ID: <447F0023.8090206@argo.co.il>
Date: Thu, 01 Jun 2006 17:56:35 +0300
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: NCQ performance (was Re: [rfc][patch] remove racy sync_page?)
References: <20060601131921.GH4400@suse.de>
In-Reply-To: <20060601131921.GH4400@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Mark Lord <lkml@rtr.ca>, Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
>
> Ok, I decided to rerun a simple random read work load (with fio), using
> depths 1 and 32. The test is simple - it does random reads all over the
> drive size with 4kb block sizes. The reads are O_DIRECT. The test
> pattern was set to repeatable, so it's going through the same workload.
> The test spans the first 32G of the drive and runtime is capped at 20
> seconds.
>

Did you modify the iodepth given to the test program, or to the drive? 
If the former, then some of the performance increase came from the Linux 
elevator.

Ideally exactly the same test would be run with the just the drive 
parameters changed.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
