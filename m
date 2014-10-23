Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 71A016B006C
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:04:45 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so862409pad.22
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 04:04:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id el11si1334408pdb.108.2014.10.23.04.04.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 04:04:44 -0700 (PDT)
Date: Thu, 23 Oct 2014 13:04:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141023110438.GQ21513@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141021162340.GA5508@gmail.com>
 <20141021170948.GA25964@node.dhcp.inet.fi>
 <20141021175603.GI3219@twins.programming.kicks-ass.net>
 <5448DB05.5050803@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5448DB05.5050803@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 23, 2014 at 06:40:05PM +0800, Lai Jiangshan wrote:
> On 10/22/2014 01:56 AM, Peter Zijlstra wrote:
> > On Tue, Oct 21, 2014 at 08:09:48PM +0300, Kirill A. Shutemov wrote:
> >> It would be interesting to see if the patchset affects non-condended case.
> >> Like a one-threaded workload.
> > 
> > It does, and not in a good way, I'll have to look at that... :/
> 
> Maybe it is blamed to find_vma_srcu() that it doesn't take the advantage of
> the vmacache_find() and cause more cache-misses.

Its what I thought initially, I tried doing perf record with and
without, but then I ran into perf diff not quite working for me and I've
yet to find time to kick that thing into shape.

> Is it hard to use the vmacache in the find_vma_srcu()?

I've not had time to look at it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
