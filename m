Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <1103601886.5121.40.camel@npiggin-nld.site>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
	 <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org>
	 <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org>
	 <1103601886.5121.40.camel@npiggin-nld.site>
Content-Type: text/plain
Date: Tue, 21 Dec 2004 15:08:09 +1100
Message-Id: <1103602089.5121.42.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-12-21 at 15:04 +1100, Nick Piggin wrote:
> On Mon, 2004-12-20 at 19:56 -0800, Linus Torvalds wrote:
> 
> > Color me convinced. 
> > 
> > Nick, can you see if such a patch is possible? I'll test ppc64 still 
> > working..
> > 
> 
> Yep, I'm beginning to think it is the way to go as well: we'll have all
> the generic code and some key architectures compiling with the struct

struct/stricter

Too much C for one day :P


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
