Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 05A536B0080
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:54:28 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so487494wgh.34
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 00:54:28 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id 8si4430015wju.88.2014.10.24.00.54.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 00:54:27 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id k14so504258wgh.19
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 00:54:26 -0700 (PDT)
Date: Fri, 24 Oct 2014 09:54:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
Message-ID: <20141024075423.GA24479@gmail.com>
References: <20141020215633.717315139@infradead.org>
 <20141021162340.GA5508@gmail.com>
 <20141021170948.GA25964@node.dhcp.inet.fi>
 <20141021175603.GI3219@twins.programming.kicks-ass.net>
 <5448DB05.5050803@cn.fujitsu.com>
 <20141023110438.GQ21513@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023110438.GQ21513@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Oct 23, 2014 at 06:40:05PM +0800, Lai Jiangshan wrote:
> > On 10/22/2014 01:56 AM, Peter Zijlstra wrote:
> > > On Tue, Oct 21, 2014 at 08:09:48PM +0300, Kirill A. Shutemov wrote:
> > >> It would be interesting to see if the patchset affects non-condended case.
> > >> Like a one-threaded workload.
> > > 
> > > It does, and not in a good way, I'll have to look at that... :/
> > 
> > Maybe it is blamed to find_vma_srcu() that it doesn't take the advantage of
> > the vmacache_find() and cause more cache-misses.
> 
> Its what I thought initially, I tried doing perf record with and
> without, but then I ran into perf diff not quite working for me and I've
> yet to find time to kick that thing into shape.

Might be the 'perf diff' regression fixed by this:

  9ab1f50876db perf diff: Add missing hists__init() call at tool start

I just pushed it out into tip:master.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
