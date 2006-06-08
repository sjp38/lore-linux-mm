Date: Thu, 8 Jun 2006 13:20:35 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] mm: tracking dirty pages -v6
In-Reply-To: <5c49b0ed0606081310q5771e8d1s55acef09b405922b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0606081318161.5498@g5.osdl.org>
References: <20060525135534.20941.91650.sendpatchset@lappy>
 <Pine.LNX.4.64.0606062056540.1507@blonde.wat.veritas.com>
 <1149770654.4408.71.camel@lappy> <5c49b0ed0606081310q5771e8d1s55acef09b405922b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nate Diller <nate.diller@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


On Thu, 8 Jun 2006, Nate Diller wrote:
> 
> Does this mean that processes dirtying pages via mmap are now subject
> to write throttling?  That could dramatically change the performance
> for tasks with a working set larger than 10% of memory.

Exactly. Except it's not a "working set", it's a "dirty set".

Which is the whole (and only) point of the whole patch.

If you want to live on the edge, you can set the dirty_balance trigger to 
something much higher, it's entirely configurable if I remember correctly.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
