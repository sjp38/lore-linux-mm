From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller in Kconfig
Date: Thu, 21 Feb 2008 15:35:38 +1100
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com>
In-Reply-To: <47BC2275.4060900@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802211535.38932.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 20 February 2008 23:52, Balbir Singh wrote:
> Andi Kleen wrote:
> > Document huge memory/cache overhead of memory controller in Kconfig
> >
> > I was a little surprised that 2.6.25-rc* increased struct page for the
> > memory controller.  At least on many x86-64 machines it will not fit into
> > a single cache line now anymore and also costs considerable amounts of
> > RAM.
>
> The size of struct page earlier was 56 bytes on x86_64 and with 64 bytes it
> won't fit into the cacheline anymore? Please also look at
> http://lwn.net/Articles/234974/

BTW. We'll probably want to increase the width of some counters
in struct page at some point for 64-bit, so then it really will
go over with the memory controller!

Actually, an external data structure is a pretty good idea. We
could probably do it easily with a radix tree (pfn->memory
controller). And that might be a better option for distros.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
