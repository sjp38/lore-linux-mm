Date: Sun, 7 May 2006 23:43:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] tracking dirty pages in shared mappings
In-Reply-To: <1146929357.3561.28.camel@lappy>
Message-ID: <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy>  <445CA22B.8030807@cyberone.com.au>
 <1146922446.3561.20.camel@lappy>  <445CA907.9060002@cyberone.com.au>
 <1146929357.3561.28.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <piggin@cyberone.com.au>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 6 May 2006, Peter Zijlstra wrote:

> Attached are both a new version of the shared_mapping_dirty patch, and
> balance_dirty_pages; to be applied in that order. 

Would you please sent patches inline? It seems that you need to initialize 
mapping to NULL in handle_pte_fault.

You could defer the page dirtying by taking a reference on the page then 
dropping the pte lock dirty the page and then drop the reference. That way 
dirtying is running without the pte lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
