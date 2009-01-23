Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B33626B0085
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 12:39:52 -0500 (EST)
Subject: Re: [PATCH] x86,mm: fix pte_free()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090123173421.GA30980@elte.hu>
References: <1232728669.4826.143.camel@laptop>
	 <20090123173421.GA30980@elte.hu>
Content-Type: text/plain
Date: Fri, 23 Jan 2009 18:39:46 +0100
Message-Id: <1232732387.4850.1.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, L-K <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-01-23 at 18:34 +0100, Ingo Molnar wrote:

> So i agree with the fix, but the patch does not look right: shouldnt that 
> be pgtable_page_dtor(pte), so that we get ->mapping cleared via 
> pte_lock_deinit()? (which i guess your intention was here - this probably 
> wont even build)

Yeah, I somehow fudged it, already send out a better one. -- One of them
days I guess :-(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
