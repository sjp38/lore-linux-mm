Date: Mon, 28 Aug 2000 16:12:52 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: How does the kernel map physical to virtual addresses?
Message-ID: <20000828161252.C1467@redhat.com>
References: <20000825233748Z130198-15329+2857@vger.kernel.org> <Pine.LNX.4.21.0008281351470.1021-100000@saturn.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0008281351470.1021-100000@saturn.homenet>; from tigran@veritas.com on Mon, Aug 28, 2000 at 01:56:34PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tigran Aivazian <tigran@veritas.com>
Cc: Timur Tabi <ttabi@interactivesi.com>, Linux MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Aug 28, 2000 at 01:56:34PM +0100, Tigran Aivazian wrote:
> 
> it is interesting to observe that many questions that deal with _details_
> are answered quickly but questions related to fundamental concepts related
> to how Linux is designed, baffle all of us (since 0 people answered). So,
> is there really nobody in the whole world who can answer this? I would
> like to know the answer (about global kernel memory layout - i.e. what
> goes into PSE pages and what goes into normal ones, and how does PAE mode
> change the picture?) myself...

If PSE is available, it is used to map the bits of the kernel's
VA which permanently maps all of physical memory.  As a result, those
pages cannot necessarily be looked up via a normal page table walk.
Anything dynamically mapped --- ie. high pages (if using PAE), or
vmalloc/ioremap pages --- is mapped using normal 4k ptes.  

mem_map[] is completely unaffected by the use of PSE, and continues to
keep one entry per 4k physical page regardless of how the page tables
have been constructed.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
