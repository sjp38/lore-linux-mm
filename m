Subject: Re: [PATCH 0/4] Lumpy Reclaim V3
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <exportbomb.1164300519@pinky>
References: <exportbomb.1164300519@pinky>
Content-Type: text/plain
Date: Thu, 23 Nov 2006 20:02:59 +0100
Message-Id: <1164308579.3878.6.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-23 at 16:48 +0000, Andy Whitcroft wrote:

> lumpy-reclaim-v2 -- Peter Zijlstra's lumpy reclaim prototype,
> 
> lumpy-cleanup-a-missplaced-comment-and-simplify-some-code --
>   cleanups to move a comment back to where it came from, to make
>   the area edge selection more comprehensible and also cleans up
>   the switch coding style to match the concensus in mm/*.c,

Sure looks better.

> lumpy-ensure-we-respect-zone-boundaries -- bug fix to ensure we do
>   not attempt to take pages from adjacent zones, and

Valid case I guess :-)

> lumpy-take-the-other-active-inactive-pages-in-the-area -- patch to
>   increase aggression over the targetted order.

Yeah, I see how this will help.

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

for all 3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
