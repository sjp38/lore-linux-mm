Date: Fri, 2 May 2008 05:19:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 0/4] remove nopfn
Message-ID: <20080502031903.GD11844@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, jk@ozlabs.org, jes@trained-monkey.org, cpw@sgi.com
List-ID: <linux-mm.kvack.org>

Hi,

Can we pretty please get this into the current merge window? All it takes
is a quick review and test ;) I think mspec was already tested, but it
wouldn't hurt to verify again...

It shaves about .5K off mm/memory.o so it is pretty significant.
Mispredicted branches are also actually a significant cost in the fault
path which I'm trying to reduce (merging fault with page_mkwrite should
help with this further).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
