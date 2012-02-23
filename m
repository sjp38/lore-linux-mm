Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2D8F06B007E
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 02:45:32 -0500 (EST)
Received: by qadz32 with SMTP id z32so7240746qad.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 23:45:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326912662-18805-1-git-send-email-asharma@fb.com>
References: <1326912662-18805-1-git-send-email-asharma@fb.com>
Date: Thu, 23 Feb 2012 13:15:30 +0530
Message-ID: <CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com>
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun Sharma <asharma@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org

On Thu, Jan 19, 2012 at 12:21 AM, Arun Sharma <asharma@fb.com> wrote:
>
> This enables malloc optimizations where we might
> madvise(..,MADV_DONTNEED) a page only to fault it
> back at a different virtual address.
>
> To ensure that we don't leak sensitive data to
> unprivileged processes, we enable this optimization
> only for pages that are reused within a memory
> cgroup.
>

So the assumption is that only apps that have access to each others
VMA's will run in this cgroup?

> The idea is to make this opt-in both at the mmap()
> level and cgroup level so the default behavior is
> unchanged after the patch.
>

Sorry, I am not convinced we need to do this

1. I know that zeroing out memory is expensive, but building a
potential loop hole is not a good idea
2. How do we ensure that tasks in a cgroup should be allowed to reuse
memory uninitialized, how does the cgroup admin know what she is
getting into?

So I am going to NACK this.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
