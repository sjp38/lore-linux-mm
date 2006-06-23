Message-ID: <449C2EC2.8050602@google.com>
Date: Fri, 23 Jun 2006 11:11:14 -0700
From: Martin Bligh <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: tracking shared dirty pages -v10
References: <20060619175243.24655.76005.sendpatchset@lappy>  <20060619175253.24655.96323.sendpatchset@lappy>  <Pine.LNX.4.64.0606222126310.26805@blonde.wat.veritas.com>  <1151019590.15744.144.camel@lappy>  <Pine.LNX.4.64.0606222305210.6483@g5.osdl.org>  <Pine.LNX.4.64.0606230759480.19782@blonde.wat.veritas.com>  <Pine.LNX.4.64.0606230955230.6265@schroedinger.engr.sgi.com> <1151083338.30819.28.camel@lappy> <Pine.LNX.4.64.0606231048020.6519@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606231048020.6519@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

>>I intent to make swap over NFS work next.
> 
> 
> I am still a bit unclear on what you mean by "work." The only 
> issue may be to consider the amount of swap pages about to be written out 
> for write throttling.

I had assumed this was a sick joke. Please tell me people aren't
really swapping over NFS. That's *insane*.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
