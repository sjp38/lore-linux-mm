Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BD96A6B00A0
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 15:27:21 -0500 (EST)
Received: by bwz28 with SMTP id 28so5596502bwz.14
        for <linux-mm@kvack.org>; Mon, 23 Feb 2009 12:27:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090223180134.GR6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <1235344649-18265-5-git-send-email-mel@csn.ul.ie>
	 <1235390101.4645.79.camel@laptop> <20090223180134.GR6740@csn.ul.ie>
Date: Mon, 23 Feb 2009 21:27:19 +0100
Message-ID: <19f34abd0902231227v687deb70r294bcf9a9b059d6@mail.gmail.com>
Subject: Re: [PATCH] mm: clean up __GFP_* flags a bit
From: Vegard Nossum <vegard.nossum@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <peterz@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

2009/2/23 Mel Gorman <mel@csn.ul.ie>:
> On Mon, Feb 23, 2009 at 12:55:01PM +0100, Peter Zijlstra wrote:
>> Subject: mm: clean up __GFP_* flags a bit
>> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> Date: Mon Feb 23 12:28:33 CET 2009
>>
>> re-sort them and poke at some whitespace alignment for easier reading.
>>
>> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> It didn't apply because we are working off different trees. I was on
> git-latest from last Wednesday and this looks to be -mm based on the presense
> of CONFIG_KMEMCHECK. I rebased and ended up with the patch below. Thanks

I will take the remaining parts and apply it to the kmemcheck tree. Thanks!


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
