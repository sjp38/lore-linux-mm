Date: Thu, 11 May 2006 16:30:36 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
In-Reply-To: <Pine.LNX.4.64.0605111546480.16571@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605111616490.3866@g5.osdl.org>
References: <1146861313.3561.13.camel@lappy> <445CA22B.8030807@cyberone.com.au>
 <1146922446.3561.20.camel@lappy> <445CA907.9060002@cyberone.com.au>
 <1146929357.3561.28.camel@lappy> <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
 <1147116034.16600.2.camel@lappy> <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
 <1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>
 <Pine.LNX.4.64.0605111546480.16571@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, piggin@cyberone.com.au, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 11 May 2006, Christoph Lameter wrote:
> On Thu, 11 May 2006, Andrew Morton wrote:
> >
> > It'd be nice to have more that a "simple test" done.  Bugs in this area
> > will be subtle and will manifest in unpleasant ways.  That goes for both
> > correctness and performance bugs.
> 
> Standard tests such as AIM7 will not trigger these paths. It is rather
> unusual for small unix processes to have a shared writable mapping and 
> therefore I doubt that the typical benchmarks may show much of a 
> difference. These  types of mappings are more typical for large or 
> specialized apps. Be sure that the tests actually do dirty 
> pages in shared writeable mappings.

What happened to the VM stress-test programs that we used to test the 
page-out with? I forget who kept a collection of them around, but they did 
things like trying to cause MM problems on purpose. And I'm pretty sure 
some of the nastiest ones used shared mappings, exactly because we've had 
problems with the virtual scanning.

I have a very distinct memory of somebody (I'd like to say Con, but that's 
probably bogus) collecting a few programs that were known to cause nasty 
problems (like the system just becoming totally unresponsive). For
checking that things degraded reasonably before getting killed by OOM.

I'm talking the 2.4.x timeframe, so it's a few years ago. It might not be 
a real _benchmark_ per se, but I think it would be an interesting 
data-point whether the system acts "better" with some of those tests..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
