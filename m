Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id B57E66B009C
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:36:34 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id 200so19718654ykr.3
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:36:34 -0800 (PST)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id h22si5347445yhf.119.2014.02.25.10.36.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 10:36:34 -0800 (PST)
Message-ID: <1393353389.2577.40.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 25 Feb 2014 10:36:29 -0800
In-Reply-To: <530CDFE0.10800@redhat.com>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
	 <530CDFE0.10800@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2014-02-25 at 13:24 -0500, Rik van Riel wrote:
> On 02/25/2014 01:16 PM, Davidlohr Bueso wrote:
> 
> > The proposed approach is to keep the current cache and adding a small, per
> > thread, LRU cache. By keeping the mm->mmap_cache, 
> 
> This bit of the changelog may want updating :)

bah, yes thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
