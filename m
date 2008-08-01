Date: Fri, 1 Aug 2008 15:09:01 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: GRU driver feedback
Message-ID: <20080801200901.GA167958@sgi.com>
References: <20080723141229.GB13247@wotan.suse.de> <20080729185315.GA14260@sgi.com> <200807301550.34500.nickpiggin@yahoo.com.au> <200807311714.05252.nickpiggin@yahoo.com.au> <20080731124039.GA27329@sgi.com> <Pine.LNX.4.64.0808011305080.20052@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808011305080.20052@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Robin Holt <holt@sgi.com>, "Torvalds, Linus" <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 01, 2008 at 01:11:09PM +0100, Hugh Dickins wrote:
> On Thu, 31 Jul 2008, Jack Steiner wrote:
> > 
> > I'm collecting the fixes & additional comments to be added & will send
> > them upstream later.
> 
> One small thing to remove if you've not already noticed:
> EXPORT_SYMBOL_GPL(follow_page) got added to mm/memory.c,
> despite our realization that GRU cannot and now does not use it.
> 

Thanks for catching this. I sent a patch upstream a few minutes ago to
remove the export.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
