Date: Thu, 9 Dec 2004 14:52:59 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page fault scalability patch V12: rss tasklist vs sloppy rss
Message-ID: <20041209225259.GG2714@holomorphy.com>
References: <Pine.LNX.4.44.0412091830580.17648-300000@localhost.localdomain> <Pine.LNX.4.58.0412091348130.7478@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412091348130.7478@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2004 at 02:02:37PM -0800, Christoph Lameter wrote:
> I was not also able to get the high numbers of > 3 mio faults with atomic
> rss + prefaulting but was able to get that with tasklist + prefault. The
> atomic version shares the locality problems with the sloppy approach.

The implementation of the atomic version at least improperly places
the counter's cacheline, so the results for that are gibberish.

Unless the algorithms being compared are properly implemented, they're
straw men, not valid comparisons.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
