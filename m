Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 583056B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 04:43:12 -0400 (EDT)
Received: by wiar9 with SMTP id r9so28339106wia.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 01:43:11 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id lg1si78568966wjc.136.2015.06.30.01.43.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jun 2015 01:43:10 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 30 Jun 2015 09:43:08 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id C1F8417D8056
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 09:44:17 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5U8h6Lf35389650
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:43:06 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5U8h65s009164
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 02:43:06 -0600
Message-ID: <55925699.5090600@linux.vnet.ibm.com>
Date: Tue, 30 Jun 2015 10:43:05 +0200
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cleaning per architecture MM hook header files
References: <1435587909-23163-1-git-send-email-ldufour@linux.vnet.ibm.com> <55924508.9080101@synopsys.com>
In-Reply-To: <55924508.9080101@synopsys.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 30/06/2015 09:28, Vineet Gupta wrote:
>> diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
>> index 769b312c1abb..2febe6ff32ed 100644
>> --- a/arch/arc/include/asm/Kbuild
>> +++ b/arch/arc/include/asm/Kbuild
>> @@ -49,3 +49,4 @@ generic-y += ucontext.h
>>  generic-y += user.h
>>  generic-y += vga.h
>>  generic-y += xor.h
>> +generic-y += mm-arch-hooks.h
>> diff --git a/arch/arc/include/asm/mm-arch-hooks.h b/arch/arc/include/asm/mm-arch-hooks.h
>> deleted file mode 100644
>> index c37541c5f8ba..000000000000
>> --- a/arch/arc/include/asm/mm-arch-hooks.h
>> +++ /dev/null
>> @@ -1,15 +0,0 @@
>> -/*
>> - * Architecture specific mm hooks
>> - *
>> - * Copyright (C) 2015, IBM Corporation
>> - * Author: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> - *
>> - * This program is free software; you can redistribute it and/or modify
>> - * it under the terms of the GNU General Public License version 2 as
>> - * published by the Free Software Foundation.
>> - */
>> -
>> -#ifndef _ASM_ARC_MM_ARCH_HOOKS_H
>> -#define _ASM_ARC_MM_ARCH_HOOKS_H
>> -
>> -#endif /* _ASM_ARC_MM_ARCH_HOOKS_H */
>> diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
>> index 83c50193626c..870a2f7cbada 100644
>> --- a/arch/arm/include/asm/Kbuild
>> +++ b/arch/arm/include/asm/Kbuild
>> @@ -36,3 +36,4 @@ generic-y += termios.h
>>  generic-y += timex.h
>>  generic-y += trace_clock.h
>>  generic-y += unaligned.h
>> +generic-y += mm-arch-hooks.h
> 
> We keep this file sorted by headers so please can u respin with right ordering !

Sure, I will send a new version.

Thanks for the review,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
