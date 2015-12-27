Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 70F0182F65
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 14:04:25 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id k129so66099503yke.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 11:04:25 -0800 (PST)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id y2si15807554ywc.240.2015.12.27.11.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Dec 2015 11:04:24 -0800 (PST)
Received: by mail-yk0-x236.google.com with SMTP id k129so66099406yke.0
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 11:04:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151227133330.GA20823@nazgul.tnic>
References: <20151226103252.GA21988@pd.tnic>
	<CALCETrUWmT7jwMvcS+NgaRKc7wpoZ5f_dGT8no7dOWFAGvKtmQ@mail.gmail.com>
	<CA+8MBbL9M9GD6NEPChO7_g_HrKZcdrne0LYXdQu18t3RqNGMfQ@mail.gmail.com>
	<CALCETrUhqQO4anRK+i4OdtRBZ9=0aVbZ-zZtuZ0QHt-O7fOkgg@mail.gmail.com>
	<CALCETrU3OCVJoBWXcdmy-9Rr3d3rJ93606K1vC3V9zfT2bQc2g@mail.gmail.com>
	<CA+8MBbJcw8dRW3DBYW-EhcOiGYFCm7HUxwG-df67wJCOqMpz0A@mail.gmail.com>
	<20151227100919.GA19398@nazgul.tnic>
	<CALCETrUcSB8ix0HSPyTwXT46gMAE2iGVZ8V1kEbkQVxVqrQFiQ@mail.gmail.com>
	<6c0b3214-f120-47ee-b7fe-677b4f27f039@email.android.com>
	<CALCETrVY7407jf-o4n1ZjKu=QNfUv9fnbxDQwX8Sa=o4PY+aFA@mail.gmail.com>
	<20151227133330.GA20823@nazgul.tnic>
Date: Sun, 27 Dec 2015 11:04:24 -0800
Message-ID: <CAPcyv4j9=OtEpsPwnCFLdUEJxCp5aUhaT5tP5k1n0TRiNbZi8Q@mail.gmail.com>
Subject: Re: [PATCHV5 3/3] x86, ras: Add __mcsafe_copy() function to recover
 from machine checks
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Tony Luck <tony.luck@gmail.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "elliott@hpe.com" <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Dec 27, 2015 at 5:33 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Sun, Dec 27, 2015 at 05:25:45AM -0800, Andy Lutomirski wrote:
>> That could significantly bloat the kernel image.
>
> Yeah, we probably should build an allyesconfig and see how big
> __ex_table is and compute how much actually that bloat would be,
> because...
>
>> Anyway, the bit 31 game isn't so bad IMO because it's localized to the
>> extable macros and the extable reader, whereas the bit 63 thing is all
>> tangled up with the __mcsafe_copy thing, and that's just the first
>> user of a more general mechanism.
>>
>> Did you see this:
>>
>> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=strict_uaccess_fixups/patch_v1&id=16644d9460fc6531456cf510d5efc57f89e5cd34
>
> ... the problem this has is that you have 4 classes, AFAICT. And since
> we're talking about a generic mechanism, the moment the 4 classes are
> not enough, this new scheme fails.
>
> I'm just saying...
>
> 4 classes are probably more than enough but we don't know.

Then we add support for more than 4 when/if the time comes...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
