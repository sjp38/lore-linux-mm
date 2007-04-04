Date: Wed, 4 Apr 2007 17:48:39 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070404154839.GI19587@v2.random>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 08:35:30AM -0700, Linus Torvalds wrote:
> Anyway, I'm not against this, but I can see somebody actually *wanting* 
> the ZERO page in some cases. I've used the fact for TLB testing, for 
> example, by just doing a big malloc(), and knowing that the kernel will 
> re-use the ZERO_PAGE so that I don't get any cache effects (well, at least 
> not any *physical* cache effects. Virtually indexed cached will still show 
> effects of it, of course, but I haven't cared).

Ok, those cases wanting the same zero page, could be fairly easily
converted to an mmap over /dev/zero (without having to run 4k large
mmap syscalls or nonlinear).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
