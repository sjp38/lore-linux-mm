Date: Tue, 1 May 2007 12:00:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans -- lumpy reclaim
Message-Id: <20070501120028.a4b62d6e.akpm@linux-foundation.org>
In-Reply-To: <46373A71.4030200@shadowen.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<20070501101651.GA29957@skynet.ie>
	<46373A71.4030200@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@skynet.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com, y-goto@jp.fujitsu.com, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Tue, 01 May 2007 14:02:41 +0100 Andy Whitcroft <apw@shadowen.org> wrote:

> I have some primitive stats patches which we have used performance
> testing.  Perhaps those could be brought up to date to provide better
> visibility into lumpy's operation.  Again this would be a separate patch.

Feel free to add new counters in /proc/vmstat - perhaps per-order
success and fail rates?  Monitoring the ratio between those would show
how effective lumpiness is being, perhaps.

It's always nice to see what's going on in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
