Date: Tue, 21 Dec 2004 10:13:19 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <20041221093628.GA6231@wotan.suse.de>
Message-ID: <Pine.LNX.4.44.0412211003130.25444-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 2004, Andi Kleen wrote:
> 
> Sorry, but I think that's a very bad approach. If the i386 users
> don't get warnings I will need to spend a lot of time just patching
> behind them. While x86-64 is getting more and more popular most
> hacking still happens on i386.
> 
> Please use a type safe approach that causes warnings
> and errors on i386 too. Otherwise it'll cause me much additional
> work longer term. Having the small advantage of a perhaps
> slightly easier migration for long term maintenance hazzle
> is a bad tradeoff IMHO.

I agree, that's what I was asking too: if i386 is not initially
converted to typesafe pud_t, then I'd soon want to add a patch
for that.  The type unsafe pud_t == pgd_t is great for doing a
simple conversion of all architectures in one small patch, but
no way does it exclude implementing typesafe pud_t on selected
(perhaps eventually all) architectures, both those that need it
for 4levels and those where it's advisable for build testing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
