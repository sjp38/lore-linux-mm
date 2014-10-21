Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id ADE226B007B
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 04:07:51 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id l18so687185wgh.17
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 01:07:50 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id pz9si13317114wjc.69.2014.10.21.01.07.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 01:07:47 -0700 (PDT)
Date: Tue, 21 Oct 2014 10:07:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
Message-ID: <20141021080740.GJ23531@worktop.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.419869904@infradead.org>
 <CA+55aFwd04q+O5ejbmDL-H7_GB6DEBMiiHkn+2R1u4uWxfDO9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwd04q+O5ejbmDL-H7_GB6DEBMiiHkn+2R1u4uWxfDO9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Al Viro <viro@zeniv.linux.org.uk>, Lai Jiangshan <laijs@cn.fujitsu.com>, Davidlohr Bueso <dave@stgolabs.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Mon, Oct 20, 2014 at 04:41:45PM -0700, Linus Torvalds wrote:
> On Mon, Oct 20, 2014 at 2:56 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > Manage the VMAs with SRCU such that we can do a lockless VMA lookup.
> 
> Can you explain why srcu, and not plain regular rcu?
> 
> Especially as you then *note* some of the problems srcu can have.
> Making it regular rcu would also seem to make it possible to make the
> seqlock be just a seqcount, no?

Because we need to hold onto the RCU read side lock across the entire
fault, which can involve IO and all kinds of other blocking ops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
