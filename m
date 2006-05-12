Date: Thu, 11 May 2006 21:51:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
In-Reply-To: <20060511080220.48688b40.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0605112146470.17921@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy> <445CA22B.8030807@cyberone.com.au>
 <1146922446.3561.20.camel@lappy> <445CA907.9060002@cyberone.com.au>
 <1146929357.3561.28.camel@lappy> <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
 <1147116034.16600.2.camel@lappy> <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
 <1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, piggin@cyberone.com.au, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 May 2006, Andrew Morton wrote:

> So let's see.  We take a write fault, we mark the page dirty then we return
> to userspace which will proceed with the write and will mark the pte dirty.

The pte is marked dirty when the page is marked dirty.

> Later still, the pte will get cleaned by reclaim or by munmap or whatever
> and the page will be marked dirty and the page will again be written out. 
> Potentially needlessly.

But consistent with the way write() works on page buffers. It is rather 
surprising that one can dirty lots of mmapped pages and they are only 
written out when the process terminates.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
