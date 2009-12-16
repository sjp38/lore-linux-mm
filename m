Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D40C6B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 20:46:31 -0500 (EST)
Message-ID: <4B283BB7.4050802@agilent.com>
Date: Tue, 15 Dec 2009 17:45:27 -0800
From: Earl Chew <earl_chew@agilent.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
References: <1228379942.5092.14.camel@twins> <4B22DD89.2020901@agilent.com> <20091214192322.GA3245@bluebox.local> <4B27905B.4080006@agilent.com> <20091215210002.GA2432@local> <4B2803D8.10704@agilent.com> <20091215222811.GC2432@local> <4B2827E8.60602@agilent.com> <20091216012347.GD2432@local>
In-Reply-To: <20091216012347.GD2432@local>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Hans J. Koch" <hjk@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, gregkh@suse.de, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Hans J. Koch wrote:
> No, dma-mem would be a directory containing some more attributes. Maybe one
> called "create" that allocates a new buffer.
> 
[ .. snip ..]
> Writing the size to that supposed "create" attribute could allocate the
> buffer and and create more attributes that contain the information you need.

Hmm ... I can't see how to make this into a transaction.

Suppose two threads write to /sys/.../create simultaneously (or
very close together) and further suppose that each call succeeds.

It's not clear to me how each can figure out where to find the
outcome of its operation because write() doesn't return anything
other than the number of octets written.

Writing "id, size" might work, but sorting out a good enough id
might be a little clunky. A process id wouldn't be good enough (with
different threads), and a thread id might get recycled.

Any other ideas ?

Earl



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
