Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E44A16B0499
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:50:01 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t138so1284137wmt.6
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:50:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m188si1843131wme.155.2017.08.25.14.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 14:50:00 -0700 (PDT)
Date: Fri, 25 Aug 2017 14:49:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: fadvise: avoid fadvise for fs without backing
 device
Message-Id: <20170825144957.5d99dad605fed1dc2550d25c@linux-foundation.org>
In-Reply-To: <CALvZod444NZaw9wcdSMs5Y60a0cV4j9SEt-TLBJT34OJ_yg3CQ@mail.gmail.com>
References: <20170818011023.181465-1-shakeelb@google.com>
	<CALvZod444NZaw9wcdSMs5Y60a0cV4j9SEt-TLBJT34OJ_yg3CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 17 Aug 2017 18:20:17 -0700 Shakeel Butt <shakeelb@google.com> wrote:

> +linux-mm, linux-kernel
> 
> On Thu, Aug 17, 2017 at 6:10 PM, Shakeel Butt <shakeelb@google.com> wrote:
> > The fadvise() manpage is silent on fadvise()'s effect on
> > memory-based filesystems (shmem, hugetlbfs & ramfs) and pseudo
> > file systems (procfs, sysfs, kernfs). The current implementaion
> > of fadvise is mostly a noop for such filesystems except for
> > FADV_DONTNEED which will trigger expensive remote LRU cache
> > draining. This patch makes the noop of fadvise() on such file
> > systems very explicit.
> >
> > However this change has two side effects for ramfs and one for
> > tmpfs. First fadvise(FADV_DONTNEED) can remove the unmapped clean
> > zero'ed pages of ramfs (allocated through read, readahead & read
> > fault) and tmpfs (allocated through read fault). Also
> > fadvise(FADV_WILLNEED) on create such clean zero'ed pages for
> > ramfs.

That sentence makes no sense.  I assume "fadvise(FADV_WILLNEED) will
create"?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
