Subject: Re: 2.6.22 -mm merge plans -- lumpy reclaim
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <46373A71.4030200@shadowen.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <20070501101651.GA29957@skynet.ie>  <46373A71.4030200@shadowen.org>
Content-Type: text/plain
Date: Tue, 01 May 2007 20:03:49 +0200
Message-Id: <1178042629.24217.5.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-01 at 14:02 +0100, Andy Whitcroft wrote:

> Perhaps Peter would have some time to take a look over the latest stack
> as it appears in -mm when that releases; ping me for a patch kit if you
> want it before then :).

Lumpy-reclaim -v7, as per the roll-up provided privately;

Code is looking good, I like what you did to it :-)

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
