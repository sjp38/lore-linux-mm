Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id ED9406B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 22:40:26 -0400 (EDT)
Message-ID: <5083608E.6040209@redhat.com>
Date: Sat, 20 Oct 2012 22:40:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: question on NUMA page migration
References: <5081777A.8050104@redhat.com> <50836060.4050408@gmail.com>
In-Reply-To: <50836060.4050408@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>

On 10/20/2012 10:39 PM, Ni zhan Chen wrote:
> On 10/19/2012 11:53 PM, Rik van Riel wrote:
>> Hi Andrea, Peter,
>>
>> I have a question on page refcounting in your NUMA
>> page migration code.
>>
>> In Peter's case, I wonder why you introduce a new
>> MIGRATE_FAULT migration mode. If the normal page
>> migration / compaction logic can do without taking
>> an extra reference count, why does your code need it?
>
> Hi Rik van Riel,
>
> This is which part of codes? Why I can't find MIGRATE_FAULT in latest
> v3.7-rc2?

It is in tip.git in the numa/core branch.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
