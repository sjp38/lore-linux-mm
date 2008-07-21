Date: Mon, 21 Jul 2008 11:14:12 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Message-ID: <20080721111412.0bfcd09b@bree.surriel.com>
In-Reply-To: <200807211549.00770.nickpiggin@yahoo.com.au>
References: <87y73x4w6y.fsf@saeurebad.de>
	<2f11576a0807201709q45aeec3cvb99b0049421245ae@mail.gmail.com>
	<20080720184843.9f7b48e9.akpm@linux-foundation.org>
	<200807211549.00770.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@saeurebad.de>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 21 Jul 2008 15:49:00 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> It is already bad because: if you are doing a big streaming copy
> which you know is going to blow the cache and not be used again,
> then you should be unmapping behind you as you go.

MADV_SEQUENTIAL exists for a reason.

If you think that doing an automatic unmap-behind will be
a better way to go, we can certainly whip up a patch for
that...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
