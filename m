Message-ID: <419B4E51.8050101@tebibyte.org>
Date: Wed, 17 Nov 2004 14:12:49 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <20041111112922.GA15948@logos.cnet>	<4193E056.6070100@tebibyte.org>	<4194EA45.90800@tebibyte.org>	<20041113233740.GA4121@x30.random>	<20041114094417.GC29267@logos.cnet>	<20041114170339.GB13733@dualathlon.random>	<20041114202155.GB2764@logos.cnet>	<419A2B3A.80702@tebibyte.org>	<419B14F9.7080204@tebibyte.org> <20041117012346.5bfdf7bc.akpm@osdl.org>
In-Reply-To: <20041117012346.5bfdf7bc.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: marcelo.tosatti@cyclades.com, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au, riel@redhat.com, mmokrejs@ribosome.natur.cuni.cz, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


Andrew Morton escreveu:
> Please ignore the previous patch and try the below.

Running 2.6.10-rc2-mm1 with just your new patch. It's got through the
first tests, building umlsim whilst simultaneously doing an 'emerge
sync' (this is a Gentoo box). I'll now try harder to break it.

> It looks like Rik's analysis is correct: when the caller doesn't have
> the swap token it just cannot reclaim referenced pages and scans its
> way into an oom.  Defeating that logic when we've hit the highest
> scanning priority does seem to fix the problem and those nice qsbench
> numbers which the thrashing control gave us appear to be unaffected.

I assume Rik's analysis was not copied to the list? If it was I missed 
it. Is your summary fairly complete?

Regards,
Chris R.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
