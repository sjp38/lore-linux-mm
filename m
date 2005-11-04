Received: from thermo.lanl.gov (thermo.lanl.gov [128.165.59.202])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with SMTP id jA4H43U1008902
	for <linux-mm@kvack.org>; Fri, 4 Nov 2005 10:04:03 -0700
Subject: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-Id: <20051104170359.80947184684@thermo.lanl.gov>
Date: Fri,  4 Nov 2005 10:03:59 -0700 (MST)
From: andy@thermo.lanl.gov (Andy Nelson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>






>On Fri, 4 Nov 2005, Andy Nelson wrote:
>> 
>> My measurements of factors of 3-4 on more than one hw arch don't
>> mean anything then?
>
>When I _know_ that modern hardware does what you tested at least two 
>orders of magnitude better than the hardware you tested?


Ok. In other posts you have skeptically accepted Power as a
`modern' architecture. I have just now dug out some numbers
of a slightly different problem running on a Power 5. Specifically
a IBM p575 I think. These tests were done in June, while the others
were done more than 2.5 years ago. In other words, there may be 
other small tuning optimizations that have gone in since then too.

The problem is a different configuration of particles, and about
2 times bigger (7Million) than the one in comp.arch (3million I think).
I would estimate that the data set in this test spans something like
2-2.5GB or so.

Here are the results:

cpus    4k pages   16m pages
1       4888.74s   2399.36s
2       2447.68s   1202.71s
4       1225.98s    617.23s
6        790.05s    418.46s
8        592.26s    310.03s
12       398.46s    210.62s
16       296.19s    161.96s
 

These numbers were on a recent Linux. I don't know which one.

Now it looks like it is down to a factor 2 or slightly more. That
is a totally different arch, that I think you have accepted as 
`modern', running the OS that you say doesn't need big page support. 

Still a bit more than insignificant I would say.


>Think about it. 

Likewise.


Andy





  
  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
