Date: Fri, 1 Aug 2008 13:11:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: GRU driver feedback
In-Reply-To: <20080731124039.GA27329@sgi.com>
Message-ID: <Pine.LNX.4.64.0808011305080.20052@blonde.site>
References: <20080723141229.GB13247@wotan.suse.de> <20080729185315.GA14260@sgi.com>
 <200807301550.34500.nickpiggin@yahoo.com.au> <200807311714.05252.nickpiggin@yahoo.com.au>
 <20080731124039.GA27329@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, "Torvalds, Linus" <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2008, Jack Steiner wrote:
> 
> I'm collecting the fixes & additional comments to be added & will send
> them upstream later.

One small thing to remove if you've not already noticed:
EXPORT_SYMBOL_GPL(follow_page) got added to mm/memory.c,
despite our realization that GRU cannot and now does not use it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
