Message-ID: <4193E056.6070100@tebibyte.org>
Date: Thu, 11 Nov 2004 22:57:42 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <20041111112922.GA15948@logos.cnet>
In-Reply-To: <20041111112922.GA15948@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@novell.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


Marcelo Tosatti escreveu:
> This is an improved version of OOM-kill-from-kswapd patch.

It seems good. My normal repeatable test of building umlsim on my 64MB 
P2 builds fine with this patch. On recent unpatched kernels it's 
guaranteed to fail when the oom killer strikes at the linking stage.

Regards,
Chris R.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
