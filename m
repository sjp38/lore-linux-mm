Subject: Re: blk_congestion_wait racy?
Message-ID: <OFF79FE9F7.73A1504E-ONC1256E54.006825BF-C1256E54.0068C4F9@de.ibm.com>
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Thu, 11 Mar 2004 20:04:21 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>




> Yes, sorry, all the world's an x86 :( Could you please send me whatever
> diffs were needed to get it all going?

I am just preparing that mail :-)

> I thought you were running a 256MB machine?  Two seconds for 400 megs of
> swapout?  What's up?

Roughly 400 MB of swapout. And two seconds isn't that bad ;-)

> An ouch-per-second sounds reasonable.  It could simply be that the CPUs
> were off running other tasks - those timeout are less than scheduling
> quanta.

I don't understand why an ouch-per-second is reasonable. The mempig is
the only process that runs on the machine and the blk_congestion_wait
uses HZ/10 as timeout value. I'd expect about 100 ouches for the 10
seconds the test runs.

The 4x performance difference remains not understood.


blue skies,
   Martin

Linux/390 Design & Development, IBM Deutschland Entwicklung GmbH
Schonaicherstr. 220, D-71032 Boblingen, Telefon: 49 - (0)7031 - 16-2247
E-Mail: schwidefsky@de.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
