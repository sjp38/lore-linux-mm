Date: Mon, 20 Dec 2004 10:52:24 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH 10/10] alternate 4-level page tables patches
In-Reply-To: <Pine.LNX.4.58.0412201041000.4112@ppc970.osdl.org>
Message-ID: <Pine.LNX.4.58.0412201047430.4112@ppc970.osdl.org>
References: <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au>
 <41C3D548.6080209@yahoo.com.au> <41C3D57C.5020005@yahoo.com.au>
 <41C3D594.4020108@yahoo.com.au> <41C3D5B1.3040200@yahoo.com.au>
 <20041218073100.GA338@wotan.suse.de> <Pine.LNX.4.58.0412181102070.22750@ppc970.osdl.org>
 <20041220174357.GB4316@wotan.suse.de> <Pine.LNX.4.58.0412201000340.4112@ppc970.osdl.org>
 <20041220181930.GH4316@wotan.suse.de> <Pine.LNX.4.58.0412201041000.4112@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Mon, 20 Dec 2004, Linus Torvalds wrote:
> 
> If you do that _first_, then sure. And have some automated checker tool
> that we can run occasionally to verify that we don't break this magic rule
> later by mistake.

Note: the reason I care so deeply is that this kind of problem tends to 
bite us _exactly_ where we don't want to be bitten: in random drivers, and 
surround code that not necessarily very many actual core developers really 
end up using. 

If some subtle issue only happens in very specific code, it's much easier 
to work around. And if it happens in core code, you can at least rest easy 
in the knowledge that many people are going to get hit by it, and we can 
thus find it easily. 

So, ironically, the worst bugs are those that affect only a small
percentage of users. You'd think that the worst bugs are those that cause 
the most problems, but it actually ends up being exactly the other way 
around: the _least_ problems or the most _subtle_ problems are the ones 
that I'm nervous about. 

				Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
