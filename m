Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6A36B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 00:33:47 -0500 (EST)
Received: by ioir85 with SMTP id r85so8263362ioi.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 21:33:47 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id c18si27231853igr.28.2015.11.16.21.33.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 21:33:46 -0800 (PST)
Received: by iouu10 with SMTP id u10so8431904iou.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 21:33:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151116194812.GJ8644@n2100.arm.linux.org.uk>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
	<1447698757-8762-12-git-send-email-ard.biesheuvel@linaro.org>
	<20151116190156.GH8644@n2100.arm.linux.org.uk>
	<CAKv+Gu8w+2GA5tV4roYtEsza+mkCZKYX_=tT2t=+eh-ZO1Y2fA@mail.gmail.com>
	<20151116194812.GJ8644@n2100.arm.linux.org.uk>
Date: Tue, 17 Nov 2015 06:33:46 +0100
Message-ID: <CAKv+Gu8H5oqrke-TpMj9i00=OJpi82NKySF40yVQoOhXbaQvXA@mail.gmail.com>
Subject: Re: [PATCH v2 11/12] ARM: wire up UEFI init and runtime support
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, Grant Likely <grant.likely@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Leif Lindholm <leif.lindholm@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, Ryan Harkin <ryan.harkin@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 16 November 2015 at 20:48, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Nov 16, 2015 at 08:04:00PM +0100, Ard Biesheuvel wrote:
>> OK. So you mean set TTBR to the zero page, perform the TLB flush and
>> only then switch to the new page tables?
>
> Not quite.
>
> If you have global mappings below TASK_SIZE, you would need this
> sequence when switching either to or from the UEFI page tables:
>
> - switch to another set of page tables which only map kernel space
>   with nothing at all in userspace.
> - flush the TLB.
> - switch to your target page tables.
>

Doh. I am so used to always having two TTBR's available, but indeed,
we shouldn't pull the rug from under our feet.

> As I say in response to one of your other patches, it's probably
> much easier to avoid any global mappings below TASK_SIZE.

Let me look into that.

Thanks,
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
