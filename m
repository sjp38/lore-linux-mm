Date: Fri, 23 Jun 2006 11:23:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
In-Reply-To: <1151085829.30819.33.camel@lappy>
Message-ID: <Pine.LNX.4.64.0606231121170.6877@schroedinger.engr.sgi.com>
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175253.24655.96323.sendpatchset@lappy>
 <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com>
 <1151019590.15744.144.camel@lappy>  <Pine.LNX.4.64.0606222305210.6483@g5.osdl.org>
  <Pine.LNX.4.64.0606230759480.19782@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0606230955230.6265@schroedinger.engr.sgi.com>
 <1151083338.30819.28.camel@lappy>  <Pine.LNX.4.64.0606231055520.6483@g5.osdl.org>
 <1151085829.30819.33.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jun 2006, Peter Zijlstra wrote:

> But the general idea is that its broken because the ACK from writeout
> can be delayed and the remaining free memory taken by other incomming
> network packets.

That is already taken care of by nr_unstable which is considered for 
write throttling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
