Date: Sun, 23 Dec 2007 17:02:16 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] mm: fix PageUptodate memory ordering bug
Message-ID: <20071223160216.GB30961@basil.nowhere.org>
References: <20071218012632.GA23110@wotan.suse.de> <20071222005737.2675c33b.akpm@linux-foundation.org> <20071223055730.GA29288@wotan.suse.de> <20071222223234.7f0fbd8a.akpm@linux-foundation.org> <20071223071529.GC29288@wotan.suse.de> <20071222232932.590e2b6c.akpm@linux-foundation.org> <20071223091405.GA15631@wotan.suse.de> <20071223012820.3a0e4db3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071223012820.3a0e4db3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Attacking that has been on my todo list forever.

I think the right way would be to define a separate Config symbol outside
the normal CPU list for this case

CONFIG_X86_BROKEN_PPRO 

or similar with Kconfig describing that it will have a large .text overhead.
Then distributions can chose to not set it.
 
> I think if we're going to do this then we should add a runtime check for the
> offending CPU then do panic("your kernel config ain't right").

Panic is not needed, it is sufficient to force the system to one 
CPU (= set cpu_possible_map to { 1 } ) and a warning to suggest
enabling CONFOG_X86_BROKEN_PPRO

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
