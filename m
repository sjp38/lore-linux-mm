Message-ID: <419B3038.3040108@tebibyte.org>
Date: Wed, 17 Nov 2004 12:04:24 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <4194EA45.90800@tebibyte.org> <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random> <20041114202155.GB2764@logos.cnet> <419A2B3A.80702@tebibyte.org> <419B14F9.7080204@tebibyte.org> <20041117012346.5bfdf7bc.akpm@osdl.org> <20041117060648.GA19107@logos.cnet> <20041117060852.GB19107@logos.cnet> <20041117063832.GC19107@logos.cnet>
In-Reply-To: <20041117063832.GC19107@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au, riel@redhat.com, mmokrejs@ribosome.natur.cuni.cz, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


Marcelo Tosatti escreveu:
> On Wed, Nov 17, 2004 at 04:08:52AM -0200, Marcelo Tosatti wrote:
> Just went on through the archives and indeed the spurious OOM kills started
> happening when the swap token code was added to the tree.

The LKML archives? We had been discussing this on Con Kolivas's list 
previously where we determined it was a problem in mainline so on Con's 
suggestion I signed up to LKML and discussed it here.

However, looking back through my mailbox the first report I made was 
2.6.8.1-ck3 *with the tbtc patches added*

I'm away to try 2.6.8.1 without....

Later,
Chris
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
