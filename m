Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0606231055520.6483@g5.osdl.org>
References: <20060619175243.24655.76005.sendpatchset@lappy>
	 <20060619175253.24655.96323.sendpatchset@lappy>
	 <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com>
	 <1151019590.15744.144.camel@lappy>
	 <Pine.LNX.4.64.0606222305210.6483@g5.osdl.org>
	 <Pine.LNX.4.64.0606230759480.19782@blonde.wat.veritas.com>
	 <Pine.LNX.4.64.0606230955230.6265@schroedinger.engr.sgi.com>
	 <1151083338.30819.28.camel@lappy>
	 <Pine.LNX.4.64.0606231055520.6483@g5.osdl.org>
Content-Type: text/plain
Date: Fri, 23 Jun 2006 20:03:49 +0200
Message-Id: <1151085829.30819.33.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-06-23 at 10:56 -0700, Linus Torvalds wrote:
> 
> On Fri, 23 Jun 2006, Peter Zijlstra wrote:
> > 
> > I intent to make swap over NFS work next.
> 
> Doesn't it work already? Is there some throttling that doesn't work?

I do not know how 'bad' the situation is now that we have the dirty page
tracking stuff, still need to create a test environment.

But the general idea is that its broken because the ACK from writeout
can be delayed and the remaining free memory taken by other incomming
network packets.

Until I have a test setup and some reproducable deadlocks I cannot say
more I'm afraid.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
