Date: Fri, 30 Mar 2007 04:23:32 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [rfc][patch 1/2] mm: dont account ZERO_PAGE
Message-ID: <20070330092332.GA3448@lnx-holt.americas.sgi.com>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330014633.GA19407@wotan.suse.de> <20070330025936.GA25722@lnx-holt.americas.sgi.com> <20070330030912.GH19407@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070330030912.GH19407@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 30, 2007 at 05:09:12AM +0200, Nick Piggin wrote:
> > up and read one word from each page to fill the page tables (not sure
> > why that was done), then forked a process for each cpu.  At that point,
>
> So not typical, but something that we'd rather not fall over with.

I agree

> I guess large ranges of zero pages could be quite common in startup
> of HPC codes operating on large matricies.

The "not sure why that was done" was referring to this being exactly the
opposite of what a typical HPC application does.  Those tend to locate
themselves on the node which will use an address range and the write
touch each of the pages.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
