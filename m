Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6E16B026B
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:48:16 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g37-v6so7354162wrd.12
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:48:16 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id j66-v6si3420222wrj.130.2018.10.04.01.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:48:15 -0700 (PDT)
Date: Thu, 4 Oct 2018 10:48:06 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004084806.GC1864@zn.tnic>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
 <20181004080321.GA3630@8bytes.org>
 <20181004081429.GB1864@zn.tnic>
 <20181004084318.GB3630@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181004084318.GB3630@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Paul Menzel <pmenzel@molgen.mpg.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Thu, Oct 04, 2018 at 10:43:18AM +0200, Joerg Roedel wrote:
> Yeah, that's what I also found out back then, the region needs to be WX.
> So we can either leave with the warning, as we know it is harmless and
> where it comes from or implement an exception in the checking code for
> that region.

The second thing is what I'm thinking too.

Or, a 3rd: not direct-map that first range at all. Commenting out the
ISA range mapping didn't have any adverse effects on my system here, for
example. But then those other mappings appeared:

https://lkml.kernel.org/r/20181003212255.GB28361@zn.tnic

for which I have no explanation yet how they came about.

This needs to be understood fully before we do anything. But it is
32-bit so it gets preempted by more important things all the time :)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
