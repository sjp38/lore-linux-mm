Date: Wed, 4 Apr 2007 18:23:53 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070404162353.GL19587@v2.random>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org> <20070404154839.GI19587@v2.random> <Pine.LNX.4.64.0704040906340.6730@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704040906340.6730@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 09:09:28AM -0700, Linus Torvalds wrote:
> You're missing the point. What if it's something like oracle that has been 
> tuned for Linux using this? Or even an open-source app that is just used 
> by big places and they see performace problems but it's not obvious *why*.
> 
> We "know" why, because we're discussing this point. But two months from 
> now, when some random company complains to SuSE/RH/whatever that their app 
> runs 5% slower or uses 200% more swap, who is going to realize what caused 
> it?

No, I'm not missing the point, I was the first to say here that such
code has been there forever and in turn I'm worried about apps
depending on it for all the wrong reasons, I even went as far as
asking a counter to avoid the waste to go unniticed, and last but not
the least that's why I'm not discussing this as internal suse fix for
the scalability issue, but only as a malinline patch for -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
