Date: Fri, 16 Mar 2001 09:10:49 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH/RFC] fix missing tlb flush on x86 smp+pae
In-Reply-To: <20010316133445.N30889@redhat.com>
Message-ID: <Pine.LNX.4.31.0103160906490.17122-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 16 Mar 2001, Stephen C. Tweedie wrote:
>
> On Intel, yes.  The PAE case is a special case: we lose one bit of
> addressing for each level of page table because the pte width has
> doubled, so the two-level page table is short of two bits of address
> coverage in PAE mode.

I would almost tend to suggest that we just always allocate the PAE. Do it
at the same time we allocate the page directory - make PAE use
"get_pgd_slow()", and just always allocate the 3 pages. Much simpler.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
