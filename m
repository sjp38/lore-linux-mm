Subject: Re: [PATCH/RFC] Add MM_DEAD flag to struct mm_struct
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1185501659.5495.174.camel@localhost.localdomain>
References: <1185501659.5495.174.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 16:41:53 +1000
Message-Id: <1185518513.5495.184.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 12:01 +1000, Benjamin Herrenschmidt wrote:
> Some architectures like sparc can do useful optimizations when knowing
> that an entire MM is being destroyed. At the moment, they rely on
> fullmm in the mmu_gather structure. However, that doesn't always work
> out very well with some of the changes we are doing. Among other things,
> the TLB flushing on sparc64 is done using per-CPU tracking data, making
> the batch not per-CPU will break that link.
> 
> So instead, we add a new flag to struct mm_struct that indicates that
> the mm is going away, for those archs to use. It also allows to use it
> in situations (such as PTE ops) where the batch isn't accessible (or
> there is no batch)

And the patch forgets to clear it in mm_init ... will send a new one
later.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
