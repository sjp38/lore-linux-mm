Subject: Re: pte_offset_map for ppc assumes HIGHPTE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <acbcf3840707251516w301f834cj5f6a81a494d359ed@mail.gmail.com>
References: <acbcf3840707251516w301f834cj5f6a81a494d359ed@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 26 Jul 2007 09:10:15 +1000
Message-Id: <1185405015.5439.369.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satya <satyakiran@gmail.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-25 at 17:16 -0500, Satya wrote:
> hello,
> The implementation of pte_offset_map() for ppc assumes that PTEs are
> kept in highmem (CONFIG_HIGHPTE). There is only one implmentation of
> pte_offset_map() as follows (include/asm-ppc/pgtable.h):
> 
> #define pte_offset_map(dir, addr)               \
>          ((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + pte_index(addr))
> 
> Shouldn't this be made conditional according to CONFIG_HIGHPTE is
> defined or not (as implemented in include/asm-i386/pgtable.h) ?
> 
> the same goes for pte_offset_map_nested and the corresponding unmap functions.

Do we have CONFIG_HIGHMEM without CONFIG_HIGHPTE ? If yes, then indeed,
we should change that. Though I'm not sure I see the point of splitting
those 2 options.

Ben.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
