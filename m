Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 175FE8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 15:00:47 -0400 (EDT)
Message-ID: <4DADDB91.4050108@redhat.com>
Date: Tue, 19 Apr 2011 14:59:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 33682] New: mprotect got stuck when THP is "always"
 enabled
References: <bug-33682-10286@https.bugzilla.kernel.org/> <20110418230651.54da5b82.akpm@linux-foundation.org> <20110419112506.GB5641@random.random> <20110419135119.GA5611@random.random>
In-Reply-To: <20110419135119.GA5611@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, bugs@casparzhang.com, Mel Gorman <mel@csn.ul.ie>

On 04/19/2011 09:51 AM, Andrea Arcangeli wrote:
> Hi,
>
> this should fix bug
> https://bugzilla.kernel.org/show_bug.cgi?id=33682 .
>
> ====
> Subject: thp: fix /dev/zero MAP_PRIVATE and vm_flags cleanups
>
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> The huge_memory.c THP page fault was allowed to run if vm_ops was null (which
> would succeed for /dev/zero MAP_PRIVATE, as the f_op->mmap wouldn't setup a
> special vma->vm_ops and it would fallback to regular anonymous memory) but
> other THP logics weren't fully activated for vmas with vm_file not NULL
> (/dev/zero has a not NULL vma->vm_file).

> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
