Date: Tue, 9 May 2006 18:24:14 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
In-Reply-To: <446133FD.6090903@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0605091819350.3718@g5.osdl.org>
References: <1146861313.3561.13.camel@lappy> <445CA22B.8030807@cyberone.com.au>
 <1146922446.3561.20.camel@lappy> <445CA907.9060002@cyberone.com.au>
 <1146929357.3561.28.camel@lappy> <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
 <1147116034.16600.2.camel@lappy> <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
 <1147207458.27680.19.camel@lappy> <17505.267.931504.918245@wombat.chubb.wattle.id.au>
 <446101BA.4000208@google.com> <Pine.LNX.4.64.0605091721460.3718@g5.osdl.org>
 <446133FD.6090903@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Martin Bligh <mbligh@google.com>, Peter Chubb <peterc@gelato.unsw.edu.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <piggin@cyberone.com.au>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Wed, 10 May 2006, Nick Piggin wrote:
> 
> Or do these databases use regular filesystem backed shared files?

Some definitely do.

I don't work much with them, but I'm pretty sure, that's exactly what 
Berkeley DB does. Probably SQLite too (and maybe MySQL?).

And I know that nntpd used to map its "newsgroup list" (which is a 
database, although not a relational one, but a really stupid line-based 
plain-text setup).

So yes, we'll impact performance. Whether it will be really noticeable or 
not, who knows.

The only way to find out may be to just apply the patches (which I'm 
currently planning on doing early after 2.6.17 unless we can get data 
otherwise) and see who screams, if anybody.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
