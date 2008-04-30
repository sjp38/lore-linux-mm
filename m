Subject: Re: [rfc] data race in page table setup/walking?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <Pine.LNX.4.64.0804292328110.23470@blonde.site>
References: <20080429050054.GC21795@wotan.suse.de>
	 <Pine.LNX.4.64.0804291333540.22025@blonde.site>
	 <1209505059.18023.193.camel@pasglop>
	 <Pine.LNX.4.64.0804292328110.23470@blonde.site>
Content-Type: text/plain
Date: Wed, 30 Apr 2008 10:09:45 +1000
Message-Id: <1209514185.18023.202.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-04-29 at 23:47 +0100, Hugh Dickins wrote:

> I am surprised it's enough to patch up the issue.

Well, we get lucky here because there's a data dependency between all
the loads... the last one needs the result from the previous one etc...

Only alpha is crazy enough to require barriers in that case as far as I
know :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
