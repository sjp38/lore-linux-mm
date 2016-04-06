Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 93E2B6B0262
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 08:29:26 -0400 (EDT)
Received: by mail-oi0-f50.google.com with SMTP id y204so55378998oie.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 05:29:26 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0071.outbound.protection.outlook.com. [157.56.112.71])
        by mx.google.com with ESMTPS id w2si923816oib.0.2016.04.06.05.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 05:29:25 -0700 (PDT)
Subject: Re: [PATCH 10/10] arch: fix has_transparent_hugepage()
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051355280.5965@eggly.anvils>
 <20160406065806.GC3078@gmail.com>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <57050111.3070507@mellanox.com>
Date: Wed, 6 Apr 2016 08:29:05 -0400
MIME-Version: 1.0
In-Reply-To: <20160406065806.GC3078@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Arnd Bergman <arnd@arndb.de>, Ralf Baechle <ralf@linux-mips.org>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@arm.linux.org.uk>, Will Deacon <will.deacon@arm.com>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On 4/6/2016 2:58 AM, Ingo Molnar wrote:
> * Hugh Dickins <hughd@google.com> wrote:
>
>> --- a/arch/x86/include/asm/pgtable.h
>> +++ b/arch/x86/include/asm/pgtable.h
>> @@ -181,6 +181,7 @@ static inline int pmd_trans_huge(pmd_t p
>>   	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
>>   }
>>   
>> +#define has_transparent_hugepage has_transparent_hugepage
>>   static inline int has_transparent_hugepage(void)
>>   {
>>   	return cpu_has_pse;
> Small nit, just writing:
>
>    #define has_transparent_hugepage
>
> ought to be enough, right?

No, since then in hugepage_init() the has_transparent_hugepage() call site
would be left with just a stray pair of parentheses instead of a call.

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
