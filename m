Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 8925A6B017D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 10:26:06 -0400 (EDT)
Message-ID: <4FE48054.5090407@redhat.com>
Date: Fri, 22 Jun 2012 10:25:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 01/11] mm: track free size between VMAs in VMA
 rbtree
References: <1340315835-28571-1-git-send-email-riel@surriel.com>   <1340315835-28571-2-git-send-email-riel@surriel.com>  <1340359115.18025.57.camel@twins> <4FE47D0E.3000804@redhat.com> <1340374439.18025.75.camel@twins>
In-Reply-To: <1340374439.18025.75.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org

On 06/22/2012 10:13 AM, Peter Zijlstra wrote:
> On Fri, 2012-06-22 at 10:11 -0400, Rik van Riel wrote:
>>
>> I am still trying to wrap my brain around your alternative
>> search algorithm, not sure if/how it can be combined with
>> arbitrary address limits and alignment...
>
> for alignment we can do: len += align - 1;

We could, but that might lead us to returning -ENOMEM
when we actually have memory available.

When you consider architectures like HPPA, which use
a pretty large alignment, but align everything the same,
chances are pretty much every freed hole will have the
right alignment...

> Will indeed need to ponder the range thing ;-)


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
