Message-ID: <41954D9A.9000303@yahoo.com.au>
Date: Sat, 13 Nov 2004 10:56:10 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <20041111112922.GA15948@logos.cnet> <4193E056.6070100@tebibyte.org> <4194EA45.90800@tebibyte.org>
In-Reply-To: <4194EA45.90800@tebibyte.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Ross <chris@tebibyte.org>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@novell.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Chris Ross wrote:
> 
> Chris Ross escreveu:
> 
>> It seems good.
> 
> 
> Sorry Marcelo, I spoke to soon. The oom killer still goes haywire even 
> with your new patch. I even got this one whilst the machine was booting!
> 
> Ignore the big numbers, they are cured by Kame's patch. I haven't 
> applied that to this kernel. This tree is pure 2.6.10-rc1-mm2 with only 
> your recent oom patch applied.
> 

But those big numbers are going to cause things to stop working properly.
You'd be best off to upgrade to the latest -mm kernel.

Thanks,
Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
