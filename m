Date: Fri, 16 Mar 2001 17:29:31 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH/RFC] fix missing tlb flush on x86 smp+pae
Message-ID: <20010316172931.V30889@redhat.com>
References: <20010316133445.N30889@redhat.com> <Pine.LNX.4.31.0103160906490.17122-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.31.0103160906490.17122-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Fri, Mar 16, 2001 at 09:10:49AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Ben LaHaise <bcrl@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Mar 16, 2001 at 09:10:49AM -0800, Linus Torvalds wrote:
> 
> > On Intel, yes.  The PAE case is a special case: we lose one bit of
> > addressing for each level of page table because the pte width has
> > doubled, so the two-level page table is short of two bits of address
> > coverage in PAE mode.
> 
> I would almost tend to suggest that we just always allocate the PAE. Do it
> at the same time we allocate the page directory - make PAE use
> "get_pgd_slow()", and just always allocate the 3 pages. Much simpler.

It would probably be worth it: the binary, libraries and stack are
going to populate all 3 pages almost immediately anyway.  I just hate
tweaking code just after we've finally got it stable. :)

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
