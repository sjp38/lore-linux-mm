Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E2F4D6B004A
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 11:14:22 -0500 (EST)
Message-ID: <4F4BABBA.9050207@redhat.com>
Date: Mon, 27 Feb 2012 11:13:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/2] mm: do not reset mm->free_area_cache on every
 single munmap
References: <20120223145417.261225fd@cuia.bos.redhat.com> <20120223150034.2c757b3a@cuia.bos.redhat.com> <m2vcmxp609.fsf@firstfloor.org>
In-Reply-To: <m2vcmxp609.fsf@firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

On 02/23/2012 04:57 PM, Andi Kleen wrote:
> Rik van Riel<riel@redhat.com>  writes:
>
>> Some programs have a large number of VMAs, and make frequent calls
>> to mmap and munmap. Having munmap constantly cause the search
>> pointer for get_unmapped_area to get reset can cause a significant
>> slowdown for such programs.
>
> This would be a much nicer patch if you split it into one that merges
> all the copy'n'paste code and another one that actually implements
> the new algorithm.

The copy'n'pasted functions are not quite the same, though.

All the ones that could be unified already have been, leaving
a few functions with actual differences around.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
