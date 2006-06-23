Message-ID: <449B98D1.3010005@namesys.com>
Date: Fri, 23 Jun 2006 00:31:29 -0700
From: Hans Reiser <reiser@namesys.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/tracking dirty pages: update get_dirty_limits for
 mmap tracking
References: <5c49b0ed0606211001s452c080cu3f55103a130b78f1@mail.gmail.com>	 <20060621180857.GA6948@wotan.suse.de> <5c49b0ed0606211525i57628af5yaef46ee4e1820339@mail.gmail.com>
In-Reply-To: <5c49b0ed0606211525i57628af5yaef46ee4e1820339@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nate Diller <nate.diller@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Linus Torvalds <torvalds@osdl.org>, "E. Gryaznova" <grev@namesys.com>
List-ID: <linux-mm.kvack.org>

Nate, you should note that A: increasing to 80% was my idea, and B: the
data from the benchmarks provide no indication that it is a good idea.

That said, it is very possible that C: the benchmark is flawed, because
the variance is so high that I am suspicious that something is wrong
with the benchmark, and D: that the implementation is flawed in some way
we don't yet see.

All that said, I cannot say that we have anything here that suggests the
change is a good change.   My intuition says it should be a good change,
but the data does not.  Not yet. 

Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
