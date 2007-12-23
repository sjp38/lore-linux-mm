Date: Sat, 22 Dec 2007 23:29:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-Id: <20071222232932.590e2b6c.akpm@linux-foundation.org>
In-Reply-To: <20071223071529.GC29288@wotan.suse.de>
References: <20071218012632.GA23110@wotan.suse.de>
	<20071222005737.2675c33b.akpm@linux-foundation.org>
	<20071223055730.GA29288@wotan.suse.de>
	<20071222223234.7f0fbd8a.akpm@linux-foundation.org>
	<20071223071529.GC29288@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 23 Dec 2007 08:15:29 +0100 Nick Piggin <npiggin@suse.de> wrote:

> > That's just speculation.  Please find out why such a small patch caused
> > such a large code size increase and see if it can be fixed.
> 
> It's not actually increasing size by that much here... hmm, do you have
> CONFIG_X86_PPRO_FENCE defined, by any chance?

I expect it was just allmodconfig, so: yes

It's a quite repeatable experiment though.

> It looks like this gets defined by default for i386, and also probably for
> distro configs. Linus? This is a fairly heavy hammer for such an unlikely bug on
> such a small number of systems (that admittedly doesn't even fix the bug in all
> cases anyway). It's not only heavy for my proposed patch, but it also halves the
> speed of spinlocks. Can we have some special config option for this instead? 

Sounds worthwhile, if we can't do it via altinstructions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
