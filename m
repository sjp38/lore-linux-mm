Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 910476B0069
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 12:28:22 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id g10so2461500pdj.18
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 09:28:22 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pp3si3688095pdb.218.2014.10.18.09.28.19
        for <linux-mm@kvack.org>;
        Sat, 18 Oct 2014 09:28:20 -0700 (PDT)
Message-ID: <54429521.80402@intel.com>
Date: Sat, 18 Oct 2014 09:28:17 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: introduce new VM_NOZEROPAGE flag
References: <1413554990-48512-1-git-send-email-dingel@linux.vnet.ibm.com>	<1413554990-48512-3-git-send-email-dingel@linux.vnet.ibm.com>	<54419265.9000000@intel.com> <20141018164928.2341415f@BR9TG4T3.de.ibm.com>
In-Reply-To: <20141018164928.2341415f@BR9TG4T3.de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Weitz <konstantin.weitz@gmail.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

On 10/18/2014 07:49 AM, Dominik Dingel wrote:
> On Fri, 17 Oct 2014 15:04:21 -0700
> Dave Hansen <dave.hansen@intel.com> wrote:
>> Is there ever a time where the VMAs under an mm have mixed VM_NOZEROPAGE
>> status?  Reading the patches, it _looks_ like it might be an all or
>> nothing thing.
> 
> Currently it is an all or nothing thing, but for a future change we might want to just
> tag the guest memory instead of the complete user address space.

I think it's a bad idea to reserve a flag for potential future use.  If
you _need_ it in the future, let's have the discussion then.  For now, I
think it should probably just be stored in the mm somewhere.

>> Full disclosure: I've got an x86-specific feature I want to steal a flag
>> for.  Maybe we should just define another VM_ARCH bit.
>>
> 
> So you think of something like:
> 
> #if defined(CONFIG_S390)
> # define VM_NOZEROPAGE	VM_ARCH_1
> #endif
> 
> #ifndef VM_NOZEROPAGE
> # define VM_NOZEROPAGE	VM_NONE
> #endif
> 
> right?

Yeah, something like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
