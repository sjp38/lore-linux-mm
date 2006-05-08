Message-ID: <445FBD1B.6080404@free.fr>
Date: Mon, 08 May 2006 23:50:19 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@free.fr>
MIME-Version: 1.0
Subject: Re: Any reason for passing "tlb" to "free_pgtables()" by address?
References: <445B2EBD.4020803@bull.net> <Pine.LNX.4.64.0605051337520.6945@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0605051337520.6945@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Zoltan Menyhart <Zoltan.Menyhart@bull.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

> Personally I'd prefer not to make your change right now - it seems
> a shame to make that cosmetic change without addressing the real
> latency issue; but I've no strong feeling against your patch.

Could you please explain what your plans are?

How much do you think it is worth to optimize "free_pgtables()",
knowing that:
- PTE, PMD and PUD pages are freed seldom (wrt. the leaf pages)
- The number of these pages is much more less than
   that of the leaf pages.

Thanks,

Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
