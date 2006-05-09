Message-ID: <446101BA.4000208@google.com>
Date: Tue, 09 May 2006 13:55:22 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
References: <1146861313.3561.13.camel@lappy>	<445CA22B.8030807@cyberone.com.au>	<1146922446.3561.20.camel@lappy>	<445CA907.9060002@cyberone.com.au>	<1146929357.3561.28.camel@lappy>	<Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>	<1147116034.16600.2.camel@lappy>	<Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>	<1147207458.27680.19.camel@lappy> <17505.267.931504.918245@wombat.chubb.wattle.id.au>
In-Reply-To: <17505.267.931504.918245@wombat.chubb.wattle.id.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <piggin@cyberone.com.au>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Peter Chubb wrote:
>>>>>>"Peter" == Peter Zijlstra <a.p.zijlstra@chello.nl> writes:
> 
> 
> Peter> From: Peter Zijlstra <a.p.zijlstra@chello.nl> People expressed
> Peter> the need to track dirty pages in shared mappings.
> 
> Peter> Linus outlined the general idea of doing that through making
> Peter> clean writable pages write-protected and taking the write
> Peter> fault.
> 
> What does this do to performance on TPC workloads?  How many extra
> faults are there likely to be?

They all use large pages anyway ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
