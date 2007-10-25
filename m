Subject: Re: [patch 3/6] arch_update_pgd call
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <20071025181901.591007141@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.591007141@de.ibm.com>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 06:48:05 +1000
Message-Id: <1193345285.7018.21.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 20:15 +0200, Martin Schwidefsky wrote:
> plain text document attachment (003-mm-update-pgd.diff)
> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> In order to change the layout of the page tables after an mmap has
> crossed the adress space limit of the current page table layout a
> architecture hook in get_unmapped_area is needed. The arguments
> are the address of the new mapping and the length of it.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

I'm not at all fan of the hook there and it's name...

Any reason why you can't do that in your arch gua ?

If not, then why can't you call it something nicer, like
arch_rebalance_pgtables() ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
