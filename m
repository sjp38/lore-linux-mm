Date: Wed, 18 Jan 2006 11:27:13 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 0/4] mm: de-skew page refcount
In-Reply-To: <20060118170558.GE28418@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0601181122120.3240@g5.osdl.org>
References: <20060118024106.10241.69438.sendpatchset@linux.site>
 <Pine.LNX.4.64.0601180830520.3240@g5.osdl.org> <20060118170558.GE28418@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>


On Wed, 18 Jan 2006, Nick Piggin wrote:
> 
> > So I disagree with this patch series. It has real downsides. There's a 
> > reason we have the offset.
> 
> Yes, there is a reason, I detailed it in the changelog and got rid of it.

And I'm not applying it. I'd be crazy to replace good code by code that is 
objectively _worse_.

The fact that you _document_ that it's worse doesn't make it any better.

The places that you improve (in the other patches) seem to have nothing at 
all to do with the counter skew issue, so I don't see the point.

So let me repeat: WHY DID YOU MAKE THE CODE WORSE?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
