Date: Wed, 21 Jun 2006 23:07:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/6] mm: tracking shared dirty pages
In-Reply-To: <20060621225639.4c8bad93.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606212305240.25441@schroedinger.engr.sgi.com>
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175253.24655.96323.sendpatchset@lappy> <20060621225639.4c8bad93.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, dhowells@redhat.com, christoph@lameter.com, mbligh@google.com, npiggin@suse.de, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2006, Andrew Morton wrote:

> Performance testing is critical here.  I think some was done, but I don't
> reall what tests were performed, nor do I remember the results.  Without such
> info it's not possible to make a go/no-go decision.

Tests did show that there was no performance regression for the usual 
tests. That is to be expected since the patch should only modify the 
behavior of shared writable mapping. The use of those is rare in typical 
benchmarks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
