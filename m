Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86B516B0010
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 07:13:06 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id l66-v6so7176877wmb.1
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 04:13:06 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id k125-v6si3608132wme.0.2018.10.04.04.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 04:13:05 -0700 (PDT)
Date: Thu, 4 Oct 2018 13:12:58 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004111258.GJ1864@zn.tnic>
References: <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
 <20181004080321.GA3630@8bytes.org>
 <20181004081429.GB1864@zn.tnic>
 <6cbb9135-7e89-748f-1d55-ac105a9f8091@molgen.mpg.de>
 <20181004084946.GD1864@zn.tnic>
 <bdc5d224-91d6-eeee-c334-4b76efb56cac@molgen.mpg.de>
 <20181004105443.GH1864@zn.tnic>
 <fa6086e6-5f89-ec11-d14c-78f8f761b8b7@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <fa6086e6-5f89-ec11-d14c-78f8f761b8b7@molgen.mpg.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: =?utf-8?B?SsO2cmcgUsO2ZGVs?= <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, x86@kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Oct 04, 2018 at 01:00:42PM +0200, Paul Menzel wrote:
> While here you write, it did not.

Read again what I said:

> and I did try marking the ISA range RO in mark_rodata_ro() but the
> machine wouldn't boot after.

and the code I pasted has this:

	//      init_memory_mapping(0, ISA_END_ADDRESS);

which is disabling the direct mapping of the ISA range.

Two very different things.

And you don't absolutely need to try it because it would simply move the
warning to another address, just like it happened on my system. Because
looking at your dmesg, that E350M1 machine is very similar to the laptop
I have. But feel free if you have time on your hands... :)

> Sorry I do not understand the question. I carry the SSD drive with
> me, and connect it to the ASRock E350M1 (64-bit) or to the Lenovo
> X60 laptop and boot from it from both systems.

So it is an OS installation which you swap between two machines. I
admit, it is the first time I hear of such a use case. In that case,
yes, bitness does matter.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
