Date: Sun, 14 Nov 2004 10:16:32 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <480430000.1100456191@[10.10.2.4]>
In-Reply-To: <20041114170339.GB13733@dualathlon.random>
References: <20041111112922.GA15948@logos.cnet> <4193E056.6070100@tebibyte.org> <4194EA45.90800@tebibyte.org> <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Chris Ross <chris@tebibyte.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

> My patch compared to yours will only save .text/.data/.bss bloat (i.e.
> the opposite of what Martin was worried about) to avoid message passing
> via global variable w/o locks from task context to kswapd.

Heh, I wasn't really worried about the code size at all ... I was just 
pointing out that 1 page was a trivial amount to be worried about, in
terms of when we start reclaim.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
