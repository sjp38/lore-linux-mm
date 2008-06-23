Date: Mon, 23 Jun 2008 03:52:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix race in COW logic
Message-ID: <20080623015243.GB29413@wotan.suse.de>
References: <20080622153035.GA31114@wotan.suse.de> <Pine.LNX.4.64.0806221742330.31172@blonde.site> <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 22, 2008 at 10:35:50AM -0700, Linus Torvalds wrote:
> 
> 
> On Sun, 22 Jun 2008, Hugh Dickins wrote:
> > 
> > You have a wicked mind, and I think you're right, and the fix right.
> 
> Agreed. I think the patch is fine, although I'd personally probably like 
> it even more if the mm counter updates to follow the rmap updates.

I would definitely have done that except it would want updating everywhere
else too, making the patch a bugfix+more (and mixing subtle issues that
may very well need bisecting some day!).

As you see in the changelog, I would prefer that too. I can make a followup
to move all the counter updates afterward, and eliminate this branch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
