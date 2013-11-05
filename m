Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 869976B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 19:39:22 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kp14so7730108pab.29
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 16:39:22 -0800 (PST)
Received: from psmtp.com ([74.125.245.143])
        by mx.google.com with SMTP id yk3si12101282pac.186.2013.11.04.16.39.20
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 16:39:21 -0800 (PST)
Message-ID: <1383611954.2342.7.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/3] mm,vdso: preallocate new vmas
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 04 Nov 2013 16:39:14 -0800
In-Reply-To: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hi Andrew - 

On Thu, 2013-10-17 at 17:50 -0700, Davidlohr Bueso wrote:
> Linus recently pointed out[1] some of the amount of unnecessary work 
> being done with the mmap_sem held. This patchset is a very initial 
> approach on reducing some of the contention on this lock, and moving
> work outside of the critical region.
> 
> Patch 1 adds a simple helper function.
> 
> Patch 2 moves out some trivial setup logic in mlock related calls.
> 
> Patch 3 allows managing new vmas without requiring the mmap_sem for
> vdsos. While it's true that there are many other scenarios where
> this can be done, few are actually as straightforward as this in the
> sense that we *always* end up allocating memory anyways, so there's really
> no tradeoffs. For this reason I wanted to get this patch out in the open.

If you have no objections, could you pickup patches 1 and 2? I think
it's safe to say that patch 3 isn't worth any more discussion.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
