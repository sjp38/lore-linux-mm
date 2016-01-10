Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F744828F3
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 20:15:44 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l65so173753198wmf.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 17:15:44 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id y187si10760509wme.46.2016.01.09.17.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 17:15:43 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id b14so21211356wmb.1
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 17:15:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrUAO3gYiVpi5BO+o6=bika2D9JFZJ4xa9Ph8ArGMfftgA@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
	<CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
	<CA+8MBbLm27dmtE-njyYUdLX8LVv91O7g34NG9oLy8n04RaqkCg@mail.gmail.com>
	<CALCETrV29dB_5PrT044NYg_p2CDaOgQ9p92mSc2rzKdRrAsviw@mail.gmail.com>
	<CA+8MBbJHXTv=-OP1+dwq5KCursi8jRnWR5Mg=MavD_sVSY05eA@mail.gmail.com>
	<CALCETrUAO3gYiVpi5BO+o6=bika2D9JFZJ4xa9Ph8ArGMfftgA@mail.gmail.com>
Date: Sat, 9 Jan 2016 17:15:42 -0800
Message-ID: <CA+8MBbLZ2Di4Gx+9buTA0kcPc2+ogxw5xzOLJon=FEM5hC3bBQ@mail.gmail.com>
Subject: Re: [PATCH v8 1/3] x86: Expand exception table to allow new handling options
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dan Williams <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Robert <elliott@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>

On Sat, Jan 9, 2016 at 2:32 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> Step 1: determine that the HW context is, in principle, recoverable.
>
> Step 2: ask the handler to try to recover.
>
> Step 3: if the handler doesn't recover, panic
>
> I'm not saying that restructuring the code like this should be a
> prerequisite for merging this, but I'm wondering whether it would make
> sense at some point in the future.

For the local machine check case this all looks simple. For the broadcast
case it's pretty incompatible with the current code structure. For a machine
check triggered someplace in the kernel w/o a new style fixup handler we'd
start by saying ... "sure, that's plausible to recover from". Then after we let
all the other CPUs return from the machine check handler we'd take it
back and say "just kidding, we're going down". It might work, but it would
be a messier panic than we have now.

Definitely food for thought for some future cleanups.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
