Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 885896B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:46:25 -0400 (EDT)
Message-ID: <4FDF5B3C.1000007@redhat.com>
Date: Mon, 18 Jun 2012 12:45:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 3/6] Fix the x86-64 page colouring code to take pgoff
 into account and use that code as the basis for a generic page colouring
 code.
References: <1340029878-7966-1-git-send-email-riel@redhat.com> <1340029878-7966-4-git-send-email-riel@redhat.com> <m2k3z48twb.fsf@firstfloor.org>
In-Reply-To: <m2k3z48twb.fsf@firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, hnaz@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/18/2012 12:30 PM, Andi Kleen wrote:
> Rik van Riel<riel@redhat.com>  writes:
>
>> From: Rik van Riel<riel@surriel.com>
>>
>> Teach the generic arch_get_unmapped_area(_topdown) code to call the
>> page colouring code.
>
> What tree is that against? I cannot find x86 page colouring code in next
> or mainline.

This is against mainline.

See align_addr in arch/x86/kernel/sys_x86_64.c and the
call sites in arch_get_unmapped_area(_topdown).

On certain AMD chips, Linux tries to get certain
allocations aligned to avoid cache aliasing issues.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
