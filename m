From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16129.33029.930495.661244@laputa.namesys.com>
Date: Tue, 1 Jul 2003 16:39:33 +0400
Subject: Re: 2.5.73-mm2
In-Reply-To: <20030701110858.GF26348@holomorphy.com>
References: <20030701105134.GE26348@holomorphy.com>
	<Pine.LNX.4.44.0307011202550.1217-100000@localhost.localdomain>
	<20030701110858.GF26348@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III writes:
 > On Tue, 1 Jul 2003, William Lee Irwin III wrote:
 > >> Well, I was mostly looking for getting handed back 0 when lowmem is
 > >> empty; I actually did realize they didn't give entirely accurate counts
 > >> of free lowmem pages.
 > 
 > On Tue, Jul 01, 2003 at 12:08:03PM +0100, Hugh Dickins wrote:
 > > I'm not pleading for complete accuracy, but nr_free_buffer_pages()
 > > will never hand back 0 (if your system managed to boot).
 > > It's a static count of present_pages (adjusted), not of
 > > free pages.  Or am I misreading nr_free_zone_pages()?
 > 
 > You're right. Wow, that's even more worse than I suspected.
 > 

Another thing is that if one boots with mem=X, nr_free_pagecache_pages()
returns X. However part of X (occupied by kernel image, etc) is not part
of any zone. As a result, zone actually contains fewer pages than
reported by nr_free_pagecache_pages(). With X small enough (comparable
with kernel image size, for example) this can confuse
balance_dirty_pages() enough so that throttling would never start, and
VM will oom_kill().

 > 
 > -- wli

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
