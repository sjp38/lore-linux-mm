Message-ID: <419A2B3A.80702@tebibyte.org>
Date: Tue, 16 Nov 2004 17:30:50 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <20041111112922.GA15948@logos.cnet> <4193E056.6070100@tebibyte.org> <4194EA45.90800@tebibyte.org> <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random> <20041114202155.GB2764@logos.cnet>
In-Reply-To: <20041114202155.GB2764@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrea Arcangeli <andrea@novell.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


Marcelo Tosatti escreveu:
> If its not the case, increasing the all_unreclaimable "timer" to a higher value
> than 5 seconds will certainly delay the OOM killer such to a point where 
> its not triggered until the VM reclaiming efforts make progress.
[...]
> 
> Chris, can you change the "500*HZ" in mm/vmscan.c balance_pgdat() function
> to "1000*HZ" and see what you get, please?

Changed. FWIW it's been running happily for hours without a single oom, 
including the normally guaranteed build UML test. I'll leave it running 
and see how it goes. The daily cron run is a usually a popular time for 
killing off a few essential daemons (ntpd, sshd &c), in fact I think the 
OOM Killer actually looks forward to it :)

Regards,
Chris R.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
