Received: by fk-out-0910.google.com with SMTP id z22so485704fkz.6
        for <linux-mm@kvack.org>; Thu, 31 Jul 2008 09:59:57 -0700 (PDT)
Message-ID: <4891EF8D.6010502@gmail.com>
Date: Thu, 31 Jul 2008 18:59:57 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: unify pmd_free() and __pmd_free_tlb() implementation
References: <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org> <488DF119.2000004@gmail.com> <20080729012656.566F.KOSAKI.MOTOHIRO@jp.fujitsu.com> <488DFFB0.1090107@gmail.com> <20080728133030.8b29fa5a.akpm@linux-foundation.org> <488E3020.1040701@goop.org> <488E4DEB.5010705@gmail.com> <20080731161750.GA26393@elte.hu>
In-Reply-To: <20080731161750.GA26393@elte.hu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Andrea Righi <righi.andrea@gmail.com> wrote:
> 
>> Jeremy Fitzhardinge wrote:
>>> Andrew Morton wrote:
>>>> I can second that.  See
>>>> http://userweb.kernel.org/~akpm/mmotm/broken-out/include-asm-generic-pgtable-nopmdh-macros-are-noxious-reason-435.patch
>>>>
>>>> Ingo cruelly ignored it.  Probably he's used to ignoring the comit
>>>> storm which I send in his direction - I'll need to resend it sometime.
>>>>
>>>> I'd consider that patch to be partial - we should demacroize the
>>>> surrounding similar functions too.  But that will require a bit more
>>>> testing.
>>> Its immediate neighbours should be easy enough (pmd_alloc_one, 
>>> __pmd_free_tlb), but any of the ones involving pmd_t risk #include hell 
>>> (though the earlier references to pud_t in inline functions suggest it 
>>> will work).  And pmd_addr_end is just ugly.
>>>
>>>     J
>>>
>> ok, let's start with the easiest: pmd_free() and __pmd_free_tlb().
>>
>> Following another attempt to unify the implementations using inline 
>> functions. It seems to build fine on x86 (pae / non-pae) and on 
>> x86_64. This is an RFC patch right now, not for inclusion (just asking 
>> if it could be a reasonable approach or not). And in any case this 
>> would need more testing.
>>
>> Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
>> ---
>>  arch/sparc/include/asm/pgalloc_64.h |    1 +
>>  include/asm-alpha/pgalloc.h         |    1 +
>>  include/asm-arm/pgalloc.h           |    1 -
>>  include/asm-frv/pgalloc.h           |    2 --
>>  include/asm-generic/pgtable-nopmd.h |   19 +++++++++++++++++--
>>  include/asm-ia64/pgalloc.h          |    1 +
>>  include/asm-m32r/pgalloc.h          |    2 --
>>  include/asm-m68k/motorola_pgalloc.h |    3 ++-
>>  include/asm-m68k/sun3_pgalloc.h     |    7 -------
>>  include/asm-mips/pgalloc.h          |   12 +-----------
>>  include/asm-parisc/pgalloc.h        |    2 +-
>>  include/asm-powerpc/pgalloc-32.h    |    2 --
>>  include/asm-powerpc/pgalloc-64.h    |    1 +
>>  include/asm-s390/pgalloc.h          |    1 -
>>  include/asm-sh/pgalloc.h            |    8 --------
>>  include/asm-um/pgalloc.h            |    1 +
>>  include/asm-x86/pgalloc.h           |    2 ++
>>  17 files changed, 28 insertions(+), 38 deletions(-)
> 
> the x86 bits look good to me in principle but touches a ton of 
> architectures and deals with VM issues - the perfect candidate for -mm?
> 
> 	Ingo

Yes, sounds reasonable. I'll rebase to -mm and post a new patch.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
