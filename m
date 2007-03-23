Subject: Re: [patch] rfc: introduce /dev/hugetlb
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
Content-Type: text/plain
Date: Sat, 24 Mar 2007 08:08:54 +1100
Message-Id: <1174684134.10836.74.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> -#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
> -unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
> -		unsigned long len, unsigned long pgoff, unsigned long flags);
> -#else
> -static unsigned long
> +unsigned long
>  hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>  		unsigned long len, unsigned long pgoff, unsigned long flags)
>  {
> @@ -150,7 +145,6 @@ full_search:
>  		addr = ALIGN(vma->vm_end, HPAGE_SIZE);
>  	}
>  }
> -#endif

WTF ? get_unmapped_area() -has- to be arch in some platforms like
power...

I'm trying to improve the whole get_unmapped_area() to better handle
multiple constraints (cacheability, page size, ...) though I haven't
quite yet settled on an interface I like.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
