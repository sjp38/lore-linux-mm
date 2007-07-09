Subject: Re: removing flush_tlb_mm as a generic hook ?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1183952874.3388.349.camel@localhost.localdomain>
References: <1183952874.3388.349.camel@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 09 Jul 2007 16:36:21 +1000
Message-Id: <1183962981.5961.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-09 at 13:47 +1000, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> While toying around with various MM callbacks, I found out that
> flush_tlb_mm() as a generic hook provided by the archs has been mostly
> obsoleted by the mmu_gather stuff.

And since life is always better with patches... here are two that
do fork and proc/fs/task_mmu. There should be an improvement on archs
like hash-table based ppc32 where flush_tlb_mm() currently has to walk
the page tables, which means an additional walk pass in fork. With this
patch, there will be only one pass, and it will only hit the pages that
have actually been marked RO.

I need to do some proper testing, but in copy to this, I'm posting the
patches anyway for review / comments.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
