Date: Sat, 18 Dec 2004 11:11:23 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 4/10] alternate 4-level page tables patches
Message-ID: <20041218101123.GD338@wotan.suse.de>
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3F2D6.6060107@yahoo.com.au> <20041218095050.GC338@wotan.suse.de> <41C40125.3060405@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41C40125.3060405@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

> Note that this (4/10) patch should give perfect garbage collection too
> (modulo bugs). The difference is in where the overheads lie. I suspect
> refcounting may be too much overhead (at least, SMP overhead); especially
> in light of Christoph's results.

Not sure - walking a lot of page tables is certainly worse. That is 
why the current code is so simple minded - it tries to avoid walking
too much.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
