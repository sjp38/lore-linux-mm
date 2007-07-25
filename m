From: Andreas Schwab <schwab@suse.de>
Subject: Re: pte_offset_map for ppc assumes HIGHPTE
References: <acbcf3840707251516w301f834cj5f6a81a494d359ed@mail.gmail.com>
Date: Thu, 26 Jul 2007 01:18:48 +0200
In-Reply-To: <acbcf3840707251516w301f834cj5f6a81a494d359ed@mail.gmail.com>
	(Satya's message of "Wed\, 25 Jul 2007 17\:16\:01 -0500")
Message-ID: <jewswodqcn.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Satya <satyakiran@gmail.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Satya <satyakiran@gmail.com> writes:

> hello,
> The implementation of pte_offset_map() for ppc assumes that PTEs are
> kept in highmem (CONFIG_HIGHPTE). There is only one implmentation of
> pte_offset_map() as follows (include/asm-ppc/pgtable.h):
>
> #define pte_offset_map(dir, addr)               \
>          ((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + pte_index(addr))
>
> Shouldn't this be made conditional according to CONFIG_HIGHPTE is
> defined or not

kmap_atomic is always defined with or without CONFIG_HIGHPTE.

> (as implemented in include/asm-i386/pgtable.h) ?

I don't think that needs it either.

Andreas.

-- 
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstrasse 5, 90409 Nurnberg, Germany
PGP key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
