Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id E75D46B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 15:49:32 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id w10so4154772pde.12
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:49:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dx1si11163138pbc.95.2014.10.22.12.49.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 12:49:32 -0700 (PDT)
Date: Wed, 22 Oct 2014 12:49:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] mm: introduce mm_forbids_zeropage function
Message-Id: <20141022124930.d723008daf5465be0a761b82@linux-foundation.org>
In-Reply-To: <20141022214552.0c954692@BR9TG4T3.de.ibm.com>
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
	<1413976170-42501-3-git-send-email-dingel@linux.vnet.ibm.com>
	<20141022122223.f3bef0f497941fa8e0805dbf@linux-foundation.org>
	<20141022214552.0c954692@BR9TG4T3.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On Wed, 22 Oct 2014 21:45:52 +0200 Dominik Dingel <dingel@linux.vnet.ibm.com> wrote:

> > > +#ifndef mm_forbids_zeropage
> > > +#define mm_forbids_zeropage(X)  (0)
> > > +#endif
> > 
> > Can we document this please?  What it does, why it does it.  We should
> > also specify precisely which arch header file is responsible for
> > defining mm_forbids_zeropage.
> > 
> 
> I will add a comment like:
> 
> /*
>  * To prevent common memory management code establishing
>  * a zero page mapping on a read fault.
>  * This function should be implemented within <asm/pgtable.h>.

s/function should be implemented/macro should be defined/

>  * s390 does this to prevent multiplexing of hardware bits
>  * related to the physical page in case of virtualization.
>  */
> 
> Okay?

Looks great, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
