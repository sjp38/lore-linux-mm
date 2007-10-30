Received: by nz-out-0506.google.com with SMTP id s1so1380104nze
        for <linux-mm@kvack.org>; Mon, 29 Oct 2007 18:22:27 -0700 (PDT)
Message-ID: <45a44e480710291822w5864b3beofcf432930d3e68d3@mail.gmail.com>
Date: Mon, 29 Oct 2007 21:22:26 -0400
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
In-Reply-To: <1193696211.5644.100.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
	 <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
	 <1193677302.27652.56.camel@twins>
	 <45a44e480710291051s7ffbb582x64ea9524c197b48a@mail.gmail.com>
	 <1193681839.27652.60.camel@twins> <1193696211.5644.100.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On 10/29/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> [ also, remap_vmalloc_range() suffers similar issues, only file and anon
>   have proper rmap ]
>
> I'm not sure we want full rmap for remap_pfn/vmalloc_range, but perhaps
> we could assist drivers in maintaining and using vma lists.
>
> I think page_mkclean_one() would work if you'd manually set page->index
> and iterate the vmas yourself. Although atm I'm not sure of anything so
> don't pin me on it.

:-) If it's anybody's fault, it's mine for not testing properly. My bad.

In the case of defio, I think it's no trouble to build a list of vmas
at mmap time and then to iterate through them when it's ready for
mkclean time as you suggested. I don't fully understand page->index
yet. I had thought it was only used by swap cache or file map.

On an unrelated note, I was looking for somewhere to stuff a 16 bit
offset (so that I have a cheap way to know which struct page
corresponds to which framebuffer block or offset) for another driver.
I had thought page->index was it but I think I am wrong now.

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
