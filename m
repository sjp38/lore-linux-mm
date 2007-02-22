Message-ID: <45DD88E3.2@redhat.com>
Date: Thu, 22 Feb 2007 07:13:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com> <45DCD309.5010109@redhat.com> <Pine.LNX.4.64.0702211600430.28364@schroedinger.engr.sgi.com> <45DCFD22.2020300@redhat.com> <Pine.LNX.4.64.0702211900340.29703@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702211900340.29703@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 21 Feb 2007, Rik van Riel wrote:
> 
>>>> http://linux-mm.org/PageReplacementDesign
>>> I do not see how this issue would be solved there.
>> If there is no swap space, we do not bother scanning the anonymous
>> page pool.  When swap space becomes available, we may end up scanning
>> it again.
> 
> Ok. This is for linux 3.0?

No, I think the changes can be introduced one at a time,
after each change gets benchmarked.

>> I would like to move the kernel towards something that fixes all
>> of the problem workloads, instead of thinking about one problem
>> at a time and reintroducing bugs for other workloads.
> 
> Problem workloads appear as machines grow to handle more memory.

Absolutely.  I am convinced that the whole "swappiness" thing
of scanning past the anonymous pages in order to find the page
cache pages will fall apart on 256GB systems even with somewhat
friendly workloads.

It is already falling apart on some workloads with 32GB systems
today...

>> Changes still need to be introduced incrementally, of course, but
>> I think it would be good if we had an idea where we were headed
>> in the medium (or even long) term.
> 
> That is difficult to foresee. I am pretty happy right now with what we 
> have and it seems to be adaptable enough for different workloads. I am a 
> bit concerned about the advanced page replacement algorithms since we 
> toyed with them and only found advantages for specialized workloads. LRU 
> is simple and easy to handle.

Linux hasn't been near LRU since the 2.3 days.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
