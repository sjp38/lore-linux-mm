Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 77B298D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 09:37:16 -0500 (EST)
Message-ID: <4D4ABD7F.2060208@redhat.com>
Date: Thu, 03 Feb 2011 09:36:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: too big min_free_kbytes
References: <1295841406.1949.953.camel@sli10-conroe> <20110124150033.GB9506@random.random> <20110126141746.GS18984@csn.ul.ie> <20110126152302.GT18984@csn.ul.ie> <20110126154203.GS926@random.random> <20110126163655.GU18984@csn.ul.ie> <20110126174236.GV18984@csn.ul.ie> <20110127134057.GA32039@csn.ul.ie> <20110127152755.GB30919@random.random> <20110203025808.GJ5843@random.random>
In-Reply-To: <20110203025808.GJ5843@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>

On 02/02/2011 09:58 PM, Andrea Arcangeli wrote:

> Comments welcome,
> Thanks!
> Andrea
>
>> ====
>> Subject: vmscan: kswapd must not free more than high_wmark pages

NAK

I believe we need a little bit of slack above high_wmark_pages,
to be able to even out memory pressure between zones.

Maybe free up to high_wmark_pages + min_wmark_pages ?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
