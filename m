Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 476896B0085
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 12:45:55 -0500 (EST)
Date: Fri, 23 Jan 2009 18:45:43 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] x86,mm: fix pte_free()
Message-ID: <20090123174543.GA16348@elte.hu>
References: <1232728669.4826.143.camel@laptop> <20090123173421.GA30980@elte.hu> <1232732387.4850.1.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1232732387.4850.1.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, L-K <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, 2009-01-23 at 18:34 +0100, Ingo Molnar wrote:
> 
> > So i agree with the fix, but the patch does not look right: shouldnt that 
> > be pgtable_page_dtor(pte), so that we get ->mapping cleared via 
> > pte_lock_deinit()? (which i guess your intention was here - this probably 
> > wont even build)
> 
> Yeah, I somehow fudged it, already send out a better one. -- One of them
> days I guess :-(

no problem - applied to tip/x86/urgent, thanks Peter!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
