Message-ID: <419B3ADC.1040203@tebibyte.org>
Date: Wed, 17 Nov 2004 12:49:48 +0100
From: Chris Ross <chris@tebibyte.org>
MIME-Version: 1.0
Subject: Re: [PATCH] fix spurious OOM kills
References: <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random> <20041114202155.GB2764@logos.cnet> <419A2B3A.80702@tebibyte.org> <419B14F9.7080204@tebibyte.org> <20041117012346.5bfdf7bc.akpm@osdl.org> <20041117060648.GA19107@logos.cnet> <20041117060852.GB19107@logos.cnet> <419B2CFC.7040006@tebibyte.org> <20041117070935.GF19107@logos.cnet>
In-Reply-To: <20041117070935.GF19107@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au, riel@redhat.com, mmokrejs@ribosome.natur.cuni.cz, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>


Marcelo Tosatti escreveu:
> Please test Andrew's patch, its hopefully good enough for most 
> scenarios. Extreme cases are probably still be problematic.

Will do, though currently testing 2.6.8.1 and it goes without saying 
this is a slow machine.

> What are the "tbtc" patches ? 

Token based thrashing control from Rik van Riel
http://marc.theaimsgroup.com/?l=linux-kernel&m=109122597407401&w=2

Regards,
Chris R.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
