Date: Sun, 23 Dec 2007 20:00:03 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Message-ID: <20071223200003.4540b4ad@bree.surriel.com>
In-Reply-To: <200712232322.08946.nickpiggin@yahoo.com.au>
References: <20071218211539.250334036@redhat.com>
	<200712212152.19260.nickpiggin@yahoo.com.au>
	<20071221091753.15a18935@bree.surriel.com>
	<200712232322.08946.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 23 Dec 2007 23:22:08 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> Not sure how well that translates to real world workloads, but it
> might help somewhere. Admittedly some of the patches are pretty
> complex...

I like your patch series.

They are completely orthogonal to my patches though, so I
won't tie them together by merging your series into mine :)

It looks like the majority of your patches could go into
-mm right away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
