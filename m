Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9994402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:23:10 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id y66so45465060oig.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 08:23:10 -0800 (PST)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id pp6si3680993oeb.20.2015.12.17.08.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 08:23:09 -0800 (PST)
Received: by mail-ob0-x234.google.com with SMTP id 18so60550026obc.2
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 08:23:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39F87180@ORSMSX114.amr.corp.intel.com>
References: <cover.1450283985.git.tony.luck@intel.com> <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
 <CALCETrVHqi9ixUQbeN82T14CVom1N6QegSNR+r=jtjRgcfC0kg@mail.gmail.com> <3908561D78D1C84285E8C5FCA982C28F39F87180@ORSMSX114.amr.corp.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 17 Dec 2015 08:22:50 -0800
Message-ID: <CALCETrXPM+CLwcQyusEnR7R9iQYTZO-1pSO5Y9MT7FJDycqWPA@mail.gmail.com>
Subject: Re: [PATCHV3 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Wed, Dec 16, 2015 at 2:51 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> Looks generally good.
>>
>> Reviewed-by: Andy Lutomirski <luto@kernel.org>
>
> You say that to part 1/3 ... what happens when you get to part 3/3 and you
> read my attempts at writing x86 assembly code?

I'm not at all familiar with that code, and Borislav or someone else
(Denys Vlasenko?) can probably review it much better than I can.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
