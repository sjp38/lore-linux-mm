Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A8D166B0044
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 15:15:55 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1232728669.4826.143.camel@laptop>
References: <1232728669.4826.143.camel@laptop>
Subject: Re: [PATCH] x86,mm: fix pte_free()
Date: Fri, 23 Jan 2009 20:15:04 +0000
Message-ID: <29744.1232741704@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: dhowells@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, L-K <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra <peterz@infradead.org> wrote:

> It seems all architectures except x86 and nm10300 already do this, and
> nm10300 doesn't seem to use pgtable_page_ctor(), which suggests it
> doesn't do SMP or simply doesnt do MMU at all or something.

MN10300 does not, as yet, do SMP.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
