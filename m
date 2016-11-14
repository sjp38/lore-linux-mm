Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 09B276B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 01:07:45 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id rf5so82000281pab.3
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 22:07:45 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id e17si20959514pgj.133.2016.11.13.22.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Nov 2016 22:07:43 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id i88so5584635pfk.2
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 22:07:43 -0800 (PST)
Subject: Re: [PATCH V3 1/2] mm: move vma_is_anonymous check within
 pmd_move_must_withdraw
References: <20161113150025.17942-1-aneesh.kumar@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <a8ff3bc4-45f8-fc3c-2ffe-7d25ce259513@gmail.com>
Date: Mon, 14 Nov 2016 17:07:37 +1100
MIME-Version: 1.0
In-Reply-To: <20161113150025.17942-1-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, benh@au1.ibm.com, michaele@au1.ibm.com, michael.neuling@au1.ibm.com, paulus@au1.ibm.com, "Kirill A . Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org



On 14/11/16 02:00, Aneesh Kumar K.V wrote:
> Architectures like ppc64 want to use page table deposit/withraw
> even with huge pmd dax entries. Allow arch to override the
> vma_is_anonymous check by moving that to pmd_move_must_withdraw
> function
> 

I think the changelog can be reworded a bit

Independent of whether the vma is for anonymous memory, some arches
like ppc64 would like to override pmd_move_must_withdraw(). One option
is to encapsulate the vma_is_anonymous() check for general architectures
inside pmd_move_must_withdraw() so that is always called and architectures
that need unconditional overriding can override this function. ppc64
needs to override the function when the MMU is configured to use hash
PTE's.

What do you think?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
