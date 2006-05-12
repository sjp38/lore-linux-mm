Message-ID: <44649ADC.5070904@google.com>
Date: Fri, 12 May 2006 07:25:32 -0700
From: "Martin J. Bligh" <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
References: <1146861313.3561.13.camel@lappy>	<445CA22B.8030807@cyberone.com.au>	<1146922446.3561.20.camel@lappy>	<445CA907.9060002@cyberone.com.au>	<1146929357.3561.28.camel@lappy>	<Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>	<1147116034.16600.2.camel@lappy>	<Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>	<1147207458.27680.19.camel@lappy>	<20060511080220.48688b40.akpm@osdl.org>	<Pine.LNX.4.64.0605111546480.16571@schroedinger.engr.sgi.com>	<Pine.LNX.4.64.0605111616490.3866@g5.osdl.org> <20060511164448.4686a2bd.akpm@osdl.org> <4464423D.50803@shadowen.org>
In-Reply-To: <4464423D.50803@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, clameter@sgi.com, a.p.zijlstra@chello.nl, piggin@cyberone.com.au, ak@suse.de, rohitseth@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Well for what its worth (and from this thread it may not be that much)
> the testing I did over night shows green across all the test boxes I
> have.  The tests do include fsx-linux across a limited range of filesystems.

There's no perf regressions anywhere in there either (across dbench, 
reaim, kernbench, tbench, at least) on a multitude of machines ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
