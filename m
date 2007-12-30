Date: Sun, 30 Dec 2007 17:33:15 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20071230163315.GA1384@elte.hu>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <20071222232932.590e2b6c.akpm@linux-foundation.org> <20071223091405.GA15631@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071223091405.GA15631@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <npiggin@suse.de> wrote:

> > Sounds worthwhile, if we can't do it via altinstructions.
> 
> Altinstructions means we still have code bloat, and sometimes extra 
> branches etc (an extra 900 bytes of icache in mm/ alone, even before 
> my fix). I'll let Linus or one of the x86 guys weigh in, though. It's 
> a really sad cost for distro kernels to carry.

hm, we should at minimum display a warning if the workaround is not 
enabled and such a kernel is booted on a true PPro that is affected by 
this.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
