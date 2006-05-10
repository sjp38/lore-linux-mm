Date: Tue, 9 May 2006 17:24:28 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
In-Reply-To: <446101BA.4000208@google.com>
Message-ID: <Pine.LNX.4.64.0605091721460.3718@g5.osdl.org>
References: <1146861313.3561.13.camel@lappy> <445CA22B.8030807@cyberone.com.au>
 <1146922446.3561.20.camel@lappy> <445CA907.9060002@cyberone.com.au>
 <1146929357.3561.28.camel@lappy> <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
 <1147116034.16600.2.camel@lappy> <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
 <1147207458.27680.19.camel@lappy> <17505.267.931504.918245@wombat.chubb.wattle.id.au>
 <446101BA.4000208@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <piggin@cyberone.com.au>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Tue, 9 May 2006, Martin Bligh wrote:
> Peter Chubb wrote:
> > 
> > What does this do to performance on TPC workloads?  How many extra
> > faults are there likely to be?
> 
> They all use large pages anyway ...

Yes, but we should really answer that question anyway.

I don't think anybody has really objected to this patch series, and it 
clearly seems to fix something (if nothing else, then Peter's test-program 
;), and for fairly obvious reasons _I_ approve of it.

But I've been asking people to benchmark it anyway. Becuase it _will_ hurt 
users of shared writable mappings, even if it's hopefully less of an issue 
today thanks to large pages. 

Now, the fact that it will hurt them is not a total disaster, since we 
already know that there are ways to mitigate it. However, it's still true 
that we should have the numbers, if only to perhaps be able to say that we 
don't care.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
