Date: Sat, 18 Dec 2004 10:48:32 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
Message-ID: <20041218094832.GB338@wotan.suse.de>
References: <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au> <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au> <20041218073100.GA338@wotan.suse.de> <20041218000841.1a2e83f3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041218000841.1a2e83f3.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andi Kleen <ak@suse.de>, nickpiggin@yahoo.com.au, linux-mm@kvack.org, hugh@veritas.com, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 18, 2004 at 12:08:41AM -0800, Andrew Morton wrote:
> Andi Kleen <ak@suse.de> wrote:
> >
> >  Enable unit-at-a-time by default. At least with 3.3-hammer and 3.4 
> >  it seems to work just fine. Has been tested with 3.3-hammer over
> >  several suse releases.
> 
> iirc, we turned this off because the compiler would go nuts inlining things
> and would consume too much stack:

I haven't had any report where this really happened with 3.3-hammer.

And in general in case it happens in one or two places only then it should
be fixed there with a few strategic "noinlines"

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
