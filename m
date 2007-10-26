Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9Q7eer3145864
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 07:40:40 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9Q7eeMw1622182
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:40:40 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9Q7ecCs005583
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:40:39 +0200
Subject: Re: [patch 3/6] arch_update_pgd call
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <1193345285.7018.21.camel@pasglop>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.591007141@de.ibm.com>  <1193345285.7018.21.camel@pasglop>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 09:40:37 +0200
Message-Id: <1193384437.31831.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 06:48 +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2007-10-25 at 20:15 +0200, Martin Schwidefsky wrote:
> > plain text document attachment (003-mm-update-pgd.diff)
> > From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > 
> > In order to change the layout of the page tables after an mmap has
> > crossed the adress space limit of the current page table layout a
> > architecture hook in get_unmapped_area is needed. The arguments
> > are the address of the new mapping and the length of it.
> > 
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> I'm not at all fan of the hook there and it's name...
> 
> Any reason why you can't do that in your arch gua ?
> 
> If not, then why can't you call it something nicer, like
> arch_rebalance_pgtables() ?

The name can be changed in no time. I've tried to use one of the
existing arch calls like arch_mmap_check or arch_get_unmapped_area but
it didn't work out. I really need the final address to make the call to
extend the page tables. 

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
