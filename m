Message-ID: <41C720AB.9030206@osdl.org>
Date: Mon, 20 Dec 2004 10:57:47 -0800
From: "Randy.Dunlap" <rddunlap@osdl.org>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
References: <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au> <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au> <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org> <20041220174357.GB4316@wotan.suse.de> <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org> <20041220181930.GH4316@wotan.suse.de> <Pine.LNX.4.58.0412201041000.4112@ppc970.osdl.org> <20041220185919.GB24493@wotan.suse.de>
In-Reply-To: <20041220185919.GB24493@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> 
>>If you do that _first_, then sure. And have some automated checker tool
>>that we can run occasionally to verify that we don't break this magic rule
>>later by mistake.
> 
> 
> scripts/checkstack.pl
> 
> There is probably a makefile target for it too, but I cannot find it 
> right now. Probably should be in make buildcheck.

It's in 'make checkstack'.

-- 
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
