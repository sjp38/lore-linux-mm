Subject: Re: pte_offset_map for ppc assumes HIGHPTE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <jewswodqcn.fsf@sykes.suse.de>
References: <acbcf3840707251516w301f834cj5f6a81a494d359ed@mail.gmail.com>
	 <jewswodqcn.fsf@sykes.suse.de>
Content-Type: text/plain
Date: Thu, 26 Jul 2007 09:22:45 +1000
Message-Id: <1185405765.5439.371.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Schwab <schwab@suse.de>
Cc: Satya <satyakiran@gmail.com>, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-07-26 at 01:18 +0200, Andreas Schwab wrote:
> Satya <satyakiran@gmail.com> writes:
> 
> > hello,
> > The implementation of pte_offset_map() for ppc assumes that PTEs are
> > kept in highmem (CONFIG_HIGHPTE). There is only one implmentation of
> > pte_offset_map() as follows (include/asm-ppc/pgtable.h):
> >
> > #define pte_offset_map(dir, addr)               \
> >          ((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + pte_index(addr))
> >
> > Shouldn't this be made conditional according to CONFIG_HIGHPTE is
> > defined or not
> 
> kmap_atomic is always defined with or without CONFIG_HIGHPTE.
> 
> > (as implemented in include/asm-i386/pgtable.h) ?
> 
> I don't think that needs it either.

Depends... if you have CONFIG_HIGHMEM and not CONFIG_HIGHPTE, you are wasting
time going through kmap_atomic unnecessarily no ? it will probably not do anything
because the PTE page is in lowmem but still...

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
