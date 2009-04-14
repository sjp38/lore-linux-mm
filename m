Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A6C0D5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:47:47 -0400 (EDT)
Date: Tue, 14 Apr 2009 21:48:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v3 2/6] mm, directio: fix fork vs direct-io race
	(read(2) side IOW gup(write) side)
Message-ID: <20090414194825.GD9809@random.random>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <20090414151652.C64D.A69D9226@jp.fujitsu.com> <20090414152500.C65F.A69D9226@jp.fujitsu.com> <x49ab6jyyiy.fsf@segfault.boston.devel.redhat.com> <20090414175124.GC9809@random.random> <x49hc0rxg1r.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49hc0rxg1r.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Jeff Moyer <jmoyer@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Zach Brown <zach.brown@oracle.com>, Andy Grover <andy.grover@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 14, 2009 at 02:10:08PM -0400, Jeff Moyer wrote:
> Really?  I don't actually see that in the code, have I missed it?

Checking the spinlock version, when any writer is waiting, the
sem->wait_list won't empty and down_read will wait too. The wakeup is
FIFO with __rwsem_do_wake is doing a wake-one if first one in queue is
a down_write. So it looks ok to me. asm version should have an
equivalent logic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
