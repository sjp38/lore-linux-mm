Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id CA52A6B0264
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 14:02:39 -0500 (EST)
Received: by igvg19 with SMTP id g19so81210851igv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:02:39 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id g79si18848902ioj.81.2015.11.16.11.02.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 11:02:39 -0800 (PST)
Received: by igbxm8 with SMTP id xm8so64243564igb.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 11:02:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151116190003.GG8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
	<1447698757-8762-11-git-send-email-ard.biesheuvel@linaro.org>
	<20151116190003.GG8644@n2100.arm.linux.org.uk>
Date: Mon, 16 Nov 2015 20:02:38 +0100
Message-ID: <CAKv+Gu8_AUX9FAUhLKvsuC=iuD0bqt+ZvXCRyxkC_BjFjvSspQ@mail.gmail.com>
Subject: Re: [PATCH v2 10/12] ARM: only consider memblocks with NOMAP cleared
 for linear mapping
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 16 November 2015 at 20:00, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Nov 16, 2015 at 07:32:35PM +0100, Ard Biesheuvel wrote:
>> Take the new memblock attribute MEMBLOCK_NOMAP into account when
>> deciding whether a certain region is or should be covered by the
>> kernel direct mapping.
>
> It's probably worth looking at this as a replacement to the way
> arm_memblock_steal() works, provided NOMAP doesn't result in the
> memory being passed to the kernel allocators.  Thoughts?
>

Yes. The primary reason for NOMAP is that the memory is not removed,
so we don't lose the annotation that it is memory (which might be
useful, for instance, for /dev/mem attribute handling)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
