Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0766B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 10:32:46 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so109059217pdb.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 07:32:45 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id r6si16093908pdp.208.2015.04.13.07.32.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Apr 2015 07:32:45 -0700 (PDT)
Message-ID: <552BD37A.8070505@parallels.com>
Date: Mon, 13 Apr 2015 17:32:26 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com> <9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com> <20150413115811.GA12354@node.dhcp.inet.fi> <552BB972.3010704@linux.vnet.ibm.com> <20150413131357.GC12354@node.dhcp.inet.fi> <552BC2CA.80309@linux.vnet.ibm.com> <552BC619.9080603@parallels.com> <20150413140219.GA14480@node.dhcp.inet.fi> <552BCE87.8040103@linux.vnet.ibm.com> <20150413142655.GA14646@node.dhcp.inet.fi>
In-Reply-To: <20150413142655.GA14646@node.dhcp.inet.fi>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van
 Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

>>> I initially thought it would be enough to put it into
>>> <asm-generic/mmu_context.h>, expecting it works as
>>> <asm-generic/pgtable.h>. But that's not the case.
>>>
>>> It probably worth at some point rework all <asm/mmu_context.h> to include
>>> <asm-generic/mmu_context.h> at the end as we do for <asm/pgtable.h>.
>>> But that's outside the scope of the patchset, I guess.
>>>
>>> I don't see any better candidate for such dummy header. :-/
>>
>> Clearly, I'm not confortable with a rewrite of <asm/mmu_context.h> :(
>>
>> So what about this patch, is this v3 acceptable ?
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Other than the #ifdef thing, the same:

Acked-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
