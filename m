Subject: Re: [patch 3/6] arch_update_pgd call
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <1193384437.31831.3.camel@localhost>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.591007141@de.ibm.com>  <1193345285.7018.21.camel@pasglop>
	 <1193384437.31831.3.camel@localhost>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 17:59:03 +1000
Message-Id: <1193385543.13638.0.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 09:40 +0200, Martin Schwidefsky wrote:
> On Fri, 2007-10-26 at 06:48 +1000, Benjamin Herrenschmidt wrote:
> > On Thu, 2007-10-25 at 20:15 +0200, Martin Schwidefsky wrote:
> > > plain text document attachment (003-mm-update-pgd.diff)
> > > From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > > 
> > > In order to change the layout of the page tables after an mmap has
> > > crossed the adress space limit of the current page table layout a
> > > architecture hook in get_unmapped_area is needed. The arguments
> > > are the address of the new mapping and the length of it.
> > > 
> > > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > 
> > I'm not at all fan of the hook there and it's name...
> > 
> > Any reason why you can't do that in your arch gua ?
> > 
> > If not, then why can't you call it something nicer, like
> > arch_rebalance_pgtables() ?
> 
> The name can be changed in no time. I've tried to use one of the
> existing arch calls like arch_mmap_check or arch_get_unmapped_area but
> it didn't work out. I really need the final address to make the call to
> extend the page tables. 

You arch get_unmapped_area() has it...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
