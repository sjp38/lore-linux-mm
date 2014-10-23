Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D3B1C6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 06:37:01 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so835402pad.19
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 03:37:01 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id yk7si1257577pab.135.2014.10.23.03.36.59
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 03:37:00 -0700 (PDT)
Message-ID: <5448DB05.5050803@cn.fujitsu.com>
Date: Thu, 23 Oct 2014 18:40:05 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
References: <20141020215633.717315139@infradead.org> <20141021162340.GA5508@gmail.com> <20141021170948.GA25964@node.dhcp.inet.fi> <20141021175603.GI3219@twins.programming.kicks-ass.net>
In-Reply-To: <20141021175603.GI3219@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/22/2014 01:56 AM, Peter Zijlstra wrote:
> On Tue, Oct 21, 2014 at 08:09:48PM +0300, Kirill A. Shutemov wrote:
>> It would be interesting to see if the patchset affects non-condended case.
>> Like a one-threaded workload.
> 
> It does, and not in a good way, I'll have to look at that... :/

Maybe it is blamed to find_vma_srcu() that it doesn't take the advantage of
the vmacache_find() and cause more cache-misses.


Is it hard to use the vmacache in the find_vma_srcu()?

> 
>  Performance counter stats for './multi-fault 1' (5 runs):
> 
>         73,860,251      page-faults                                                   ( +-  0.28% )
>             40,914      cache-misses                                                  ( +- 41.26% )
> 
>       60.001484913 seconds time elapsed                                          ( +-  0.00% )
> 
> 
>  Performance counter stats for './multi-fault 1' (5 runs):
> 
>         70,700,838      page-faults                                                   ( +-  0.03% )
>             31,466      cache-misses                                                  ( +-  8.62% )
> 
>       60.001753906 seconds time elapsed                                          ( +-  0.00% )
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
