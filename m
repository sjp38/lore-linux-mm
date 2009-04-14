Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DF5675F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 14:10:04 -0400 (EDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC][PATCH v3 2/6] mm, directio: fix fork vs direct-io race (read(2) side IOW gup(write) side)
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
	<20090414151652.C64D.A69D9226@jp.fujitsu.com>
	<20090414152500.C65F.A69D9226@jp.fujitsu.com>
	<x49ab6jyyiy.fsf@segfault.boston.devel.redhat.com>
	<20090414175124.GC9809@random.random>
Date: Tue, 14 Apr 2009 14:10:08 -0400
In-Reply-To: <20090414175124.GC9809@random.random> (Andrea Arcangeli's message
	of "Tue, 14 Apr 2009 19:51:24 +0200")
Message-ID: <x49hc0rxg1r.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Zach Brown <zach.brown@oracle.com>, Andy Grover <andy.grover@oracle.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <aarcange@redhat.com> writes:

> On Tue, Apr 14, 2009 at 12:45:41PM -0400, Jeff Moyer wrote:
>> So, if you're continuously submitting async read I/O, you will starve
>> out the fork() call indefinitely.  I agree that you want to allow
>
> IIRC rwsem good enough to stop the down_read when a down_write is
> blocked. Otherwise page fault flood in threads would also starve any
> mmap or similar call. Still with this approach fork will start to hang

Really?  I don't actually see that in the code, have I missed it?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
