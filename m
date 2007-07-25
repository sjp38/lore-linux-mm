Received: by wx-out-0506.google.com with SMTP id h31so531176wxd
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 15:16:01 -0700 (PDT)
Message-ID: <acbcf3840707251516w301f834cj5f6a81a494d359ed@mail.gmail.com>
Date: Wed, 25 Jul 2007 17:16:01 -0500
From: Satya <satyakiran@gmail.com>
Subject: pte_offset_map for ppc assumes HIGHPTE
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

hello,
The implementation of pte_offset_map() for ppc assumes that PTEs are
kept in highmem (CONFIG_HIGHPTE). There is only one implmentation of
pte_offset_map() as follows (include/asm-ppc/pgtable.h):

#define pte_offset_map(dir, addr)               \
         ((pte_t *) kmap_atomic(pmd_page(*(dir)), KM_PTE0) + pte_index(addr))

Shouldn't this be made conditional according to CONFIG_HIGHPTE is
defined or not (as implemented in include/asm-i386/pgtable.h) ?

the same goes for pte_offset_map_nested and the corresponding unmap functions.

thanks,
Satya Popuri

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
