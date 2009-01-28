Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 076666B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 12:59:39 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 3so83787eyh.44
        for <linux-mm@kvack.org>; Wed, 28 Jan 2009 09:59:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090127174158.519e5abd.akpm@linux-foundation.org>
References: <1232919337-21434-1-git-send-email-righi.andrea@gmail.com>
	 <20090127174158.519e5abd.akpm@linux-foundation.org>
Date: Wed, 28 Jan 2009 18:59:37 +0100
Message-ID: <a2776ec50901280959l6f96d2e0g72ce5eed665894a7@mail.gmail.com>
Subject: Re: [PATCH -mmotm] mm: unify some pmd_*() functions
From: Andrea Righi <righi.andrea@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 28, 2009 at 2:41 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 25 Jan 2009 22:35:37 +0100
> Andrea Righi <righi.andrea@gmail.com> wrote:
>
>> diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
>> index a7cdc48..b132d69 100644
>> --- a/include/asm-generic/pgtable-nopmd.h
>> +++ b/include/asm-generic/pgtable-nopmd.h
>> @@ -4,6 +4,7 @@
>>  #ifndef __ASSEMBLY__
>>
>>  #include <asm-generic/pgtable-nopud.h>
>> +#include <asm/bug.h>
>>
>>  struct mm_struct;
>>
>
> Why not include the preferred <linux/bug.h>?

Using linux/bug.h leads to include hell (i.e. on x86 with
CONFIG_X86_PAE not set):
...
  CC      arch/x86/kernel/asm-offsets.s
In file included from include/linux/thread_info.h:55,
                 from include/linux/preempt.h:9,
                 from include/linux/spinlock.h:50,
                 from include/linux/seqlock.h:29,
                 from include/linux/time.h:8,
                 from include/linux/stat.h:60,
                 from include/linux/module.h:10,
                 from include/linux/bug.h:4,
                 from include/asm-generic/pgtable-nopmd.h:7,
                 from
/home/arighi/Software/linux/mmotm/arch/x86/include/asm/page.h:132,
                 from
/home/arighi/Software/linux/mmotm/arch/x86/include/asm/processor.h:18,
                 from
/home/arighi/Software/linux/mmotm/arch/x86/include/asm/atomic_32.h:6,
                 from
/home/arighi/Software/linux/mmotm/arch/x86/include/asm/atomic.h:2,
                 from include/linux/crypto.h:20,
                 from arch/x86/kernel/asm-offsets_32.c:7,
                 from arch/x86/kernel/asm-offsets.c:2:
/home/arighi/Software/linux/mmotm/arch/x86/include/asm/thread_info.h:34:
error: expected specifier-qualifier-list before 'mm_segment_t'
...

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
