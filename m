Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 91C7C828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:50:45 -0500 (EST)
Received: by mail-lf0-f45.google.com with SMTP id h129so17029055lfh.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:50:45 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id g14si13826144lfd.41.2016.01.11.04.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 04:50:44 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: Re: [RFC 01/13] x86/paravirt: Turn KASAN off for parvirt.o
Date: Mon, 11 Jan 2016 15:51:17 +0300
Message-ID: <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <20160110185916.GD22896@pd.tnic>
References: <20160110185916.GD22896@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

On 01/10/2016 09:59 PM, Borislav Petkov wrote:
> + Andrey.
> 
> On Fri, Jan 08, 2016 at 03:15:19PM -0800, Andy Lutomirski wrote:
>> Otherwise terrible things happen if some of the callbacks end up
>> calling into KASAN in unexpected places.
>>
>> This has no obvious symptoms yet, but adding a memory reference to
>> native_flush_tlb_global without this blows up on KASAN kernels.
>>
>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>> ---
>>  arch/x86/kernel/Makefile | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
>> index b1b78ffe01d0..b7cd5bdf314b 100644
>> --- a/arch/x86/kernel/Makefile
>> +++ b/arch/x86/kernel/Makefile
>> @@ -19,6 +19,7 @@ endif
>>  KASAN_SANITIZE_head$(BITS).o := n
>>  KASAN_SANITIZE_dumpstack.o := n
>>  KASAN_SANITIZE_dumpstack_$(BITS).o := n
>> +KASAN_SANITIZE_paravirt.o := n
>>  
>>  CFLAGS_irq.o := -I$(src)/../include/asm/trace
> 
> Shouldn't we take this one irrespectively of what happens to the rest in
> the patchset?
>

I don't think that this patch is the right way to solve the problem.
The follow-up patch "x86/kasan: clear kasan_zero_page after TLB flush" should fix Andy's problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
