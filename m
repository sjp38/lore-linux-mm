Date: Tue, 18 Sep 2007 10:44:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use pagevec to rotate reclaimable page
Message-Id: <20070918104435.2ba25ff3.akpm@linux-foundation.org>
In-Reply-To: <200709181129.50253.nickpiggin@yahoo.com.au>
References: <6.0.0.20.2.20070907113025.024dfbb8@172.19.0.2>
	<20070913193711.ecc825f7.akpm@linux-foundation.org>
	<6.0.0.20.2.20070918193944.038e2ea0@172.19.0.2>
	<200709181129.50253.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007 11:29:50 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> It would be interesting to test -mm kernels. They have a patch which reduces
> zone lock contention quite a lot.

They do?  Which patch?

> I think your patch is a nice idea, and with less zone lock contention in other
> areas, it is possible that it might produce a relatively larger improvement.

I'm a bit wobbly about this patch - it adds additional single-cpu overhead
to reduce multiple-cpu overhead and latency.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
