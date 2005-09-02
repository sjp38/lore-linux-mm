Message-ID: <4318C395.1080203@yahoo.com.au>
Date: Sat, 03 Sep 2005 07:26:45 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au> <4317F136.4040601@yahoo.com.au> <Pine.LNX.4.62.0509021123290.15836@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509021123290.15836@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 2 Sep 2005, Nick Piggin wrote:
> 
> 
>>Implement atomic_cmpxchg for i386 and ppc64. Is there any
>>architecture that won't be able to implement such an operation?
> 
> 
> Something like that used to be part of the page fault scalability 
> patchset. You contributed to it last year. Here is the latest version of 
> that. May need some work though.
> 

Thanks Christoph, I think this will be required to support 386.
In the worst case, we could provide a fallback path and take
->tree_lock in pagecache lookups if there is no atomic_cmpxchg,
however I would much prefer all architectures get an atomic_cmpxchg,
and I think it should turn out to be a generally useful primitive.

I may trim this down to only provide what is needed for atomic_cmpxchg
if that is OK?

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
