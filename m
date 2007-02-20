Subject: Re: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1171919736.3531.98.camel@laptopd505.fenrus.org>
References: <20070219183123.27318.27319.stgit@localhost.localdomain>
	 <1171910581.3531.89.camel@laptopd505.fenrus.org>
	 <1171913691.22940.30.camel@localhost.localdomain>
	 <1171919736.3531.98.camel@laptopd505.fenrus.org>
Content-Type: text/plain
Date: Wed, 21 Feb 2007 06:57:40 +1100
Message-Id: <1172001460.18571.134.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> maybe. I'm not entirely convinced... (I like the cleanup potential a lot
> code wise.. but if it costs performance, then... well I'd hate to see
> linux get slower for hugetlbfs)
> 
> > If not, then I definitely wouldn't
> > mind creating a default_pagetable_ops and calling into that.
> 
> ... but without it to be honest, your patch adds nothing real.. there's
> ONE user of your code, and there's no real cleanup unless you get rid of
> all the special casing.... since the special casing is the really ugly
> part of hugetlbfs, not the actual code inside the special case..

Well... I disagree there too :-)

I've been working recently for example on some spufs improvements that
require similar tweaking of the user address space as hugetlbfs. The
problem I have is that while there are hooks in the generic code pretty
much everywhere I need.... they are all hugetlb specific, that is they
call directly into the hugetlb code.

For now, I found ways of doing my stuff without hooking all over the
page table operations (well, I had no real choices) but I can imagine it
making sense to allow something (hugetlb being one of them) to take over
part of the user address space.

Ben.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
