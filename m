Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 617106B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 04:18:38 -0500 (EST)
Received: by igcph11 with SMTP id ph11so75049274igc.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 01:18:38 -0800 (PST)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id t12si28447568igd.27.2015.11.17.01.18.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 01:18:37 -0800 (PST)
Received: by ioir85 with SMTP id r85so12433894ioi.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 01:18:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151116184919.GD8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
	<1447698757-8762-6-git-send-email-ard.biesheuvel@linaro.org>
	<20151116184919.GD8644@n2100.arm.linux.org.uk>
Date: Tue, 17 Nov 2015 10:18:37 +0100
Message-ID: <CAKv+Gu9+Pw3vv-EiZYg1zNmoBYPqcWY=XECzTcVV8WtY5WjpTg@mail.gmail.com>
Subject: Re: [PATCH v2 05/12] arm64/efi: refactor EFI init and runtime code
 for reuse by 32-bit ARM
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt.fleming@intel.com>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 16 November 2015 at 19:49, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Nov 16, 2015 at 07:32:30PM +0100, Ard Biesheuvel wrote:
>> diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
>> index e62ee5df96ca..ad11ba6964f6 100644
>> --- a/drivers/firmware/efi/arm-runtime.c
>> +++ b/drivers/firmware/efi/arm-runtime.c
>> @@ -23,18 +23,15 @@
>>
>>  #include <asm/cacheflush.h>
>>  #include <asm/efi.h>
>> -#include <asm/tlbflush.h>
>> -#include <asm/mmu_context.h>
>> +#include <asm/io.h>
>
> Shouldn't this be linux/io.h ?
>

Yes. Will change it for v3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
