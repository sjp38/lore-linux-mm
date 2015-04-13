Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 17B696B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 11:27:43 -0400 (EDT)
Received: by wiun10 with SMTP id n10so71314519wiu.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 08:27:42 -0700 (PDT)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id ek6si14529277wib.51.2015.04.13.08.27.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 08:27:41 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 13 Apr 2015 16:27:39 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 62F5C2190066
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 16:27:22 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3DFRaaf35389554
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 15:27:36 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3DFRYic000856
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 09:27:36 -0600
Message-ID: <552BE064.4000903@linux.vnet.ibm.com>
Date: Mon, 13 Apr 2015 17:27:32 +0200
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH v3 1/2] mm: Introducing arch_remap hook
References: <cover.1428916945.git.ldufour@linux.vnet.ibm.com> <9d827fc618a718830b2c47aa87e8be546914c897.1428916945.git.ldufour@linux.vnet.ibm.com> <20150413115811.GA12354@node.dhcp.inet.fi> <552BB972.3010704@linux.vnet.ibm.com> <20150413131357.GC12354@node.dhcp.inet.fi> <552BC2CA.80309@linux.vnet.ibm.com> <552BC619.9080603@parallels.com> <20150413140219.GA14480@node.dhcp.inet.fi> <552BCE87.8040103@linux.vnet.ibm.com> <20150413142655.GA14646@node.dhcp.inet.fi> <552BD37A.8070505@parallels.com>
In-Reply-To: <552BD37A.8070505@parallels.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@kernel.org>, linuxppc-dev@lists.ozlabs.org, cov@codeaurora.org, criu@openvz.org

On 13/04/2015 16:32, Pavel Emelyanov wrote:
>>>> I initially thought it would be enough to put it into
>>>> <asm-generic/mmu_context.h>, expecting it works as
>>>> <asm-generic/pgtable.h>. But that's not the case.
>>>>
>>>> It probably worth at some point rework all <asm/mmu_context.h> to include
>>>> <asm-generic/mmu_context.h> at the end as we do for <asm/pgtable.h>.
>>>> But that's outside the scope of the patchset, I guess.
>>>>
>>>> I don't see any better candidate for such dummy header. :-/
>>>
>>> Clearly, I'm not confortable with a rewrite of <asm/mmu_context.h> :(
>>>
>>> So what about this patch, is this v3 acceptable ?
>>
>> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Other than the #ifdef thing, the same:
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>
> 

Thanks Kirill and Pavel.

Should I send a new version fixing the spaces around the plus sign ?

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
