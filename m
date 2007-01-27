Date: Sat, 27 Jan 2007 09:08:58 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Don't allow the stack to grow into hugetlb reserved
 regions
In-Reply-To: <b040c32a0701261448k122f5cc7q5368b3b16ee1dc1f@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0701270904360.15686@blonde.wat.veritas.com>
References: <20070125214052.22841.33449.stgit@localhost.localdomain>
 <Pine.LNX.4.64.0701262025590.22196@blonde.wat.veritas.com>
 <b040c32a0701261448k122f5cc7q5368b3b16ee1dc1f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@osdl.org>, William Irwin <wli@holomorphy.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Ken Chen wrote:
> On 1/26/07, Hugh Dickins <hugh@veritas.com> wrote:
> > Less trivial (and I wonder whether you've come to this from an ia64
> > or a powerpc direction): I notice that ia64 has more stringent REGION
> > checks in its ia64_do_page_fault, before calling expand_stack or
> > expand_upwards.  So on that path, the usual path, I think your
> > new check in acct_stack_growth is unnecessary on ia64;
> 
> I think you are correct. This appears to affect powerpc only. On ia64,
> hugetlb lives in a completely different region and they can never step
> into normal stack address space. And for x86, there isn't a thing called
> "reserved address space" for hugetlb mapping.

Thanks, that's reassuring for the hugetlb case, and therefore Adam's
patch should not be delayed.  But it does leave open the question I
was raising in the text you've snipped: if ia64 needs those stringent
REGION checks in its ia64_do_page_fault path, don't we need to add
them some(messy)how in the get_user_pages find_extend_vma path?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
