Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 227186B0069
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 18:04:47 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so1565824pad.39
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 15:04:46 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ov3si2044972pbc.228.2014.10.17.15.04.45
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 15:04:46 -0700 (PDT)
Message-ID: <54419265.9000000@intel.com>
Date: Fri, 17 Oct 2014 15:04:21 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com> <1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On 10/17/2014 07:09 AM, Dominik Dingel wrote:
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index cd33ae2..8f09c91 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -113,7 +113,7 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
>  #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
>  #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
> -
> +#define VM_NOZEROPAGE	0x00001000	/* forbid new zero page mappings */
>  #define VM_LOCKED	0x00002000
>  #define VM_IO           0x00004000	/* Memory mapped I/O or similar */

This seems like an awfully obscure use for a very constrained resource
(VM_ flags).

Is there ever a time where the VMAs under an mm have mixed VM_NOZEROPAGE
status?  Reading the patches, it _looks_ like it might be an all or
nothing thing.

Full disclosure: I've got an x86-specific feature I want to steal a flag
for.  Maybe we should just define another VM_ARCH bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
