Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB3E6B000E
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:43:20 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g28-v6so4919667edc.18
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:43:20 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id v13-v6si3172825edi.241.2018.10.04.01.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:43:19 -0700 (PDT)
Date: Thu, 4 Oct 2018 10:43:18 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004084318.GB3630@8bytes.org>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
 <20181004080321.GA3630@8bytes.org>
 <20181004081429.GB1864@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181004081429.GB1864@zn.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Paul Menzel <pmenzel@molgen.mpg.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Thu, Oct 04, 2018 at 10:14:38AM +0200, Borislav Petkov wrote:
> So looking at this, BIOS_BEGIN and BIOS_END is the same range as the ISA
> range:
> 
> #define ISA_START_ADDRESS       0x000a0000
> #define ISA_END_ADDRESS         0x00100000
> 
> #define BIOS_BEGIN              0x000a0000
> #define BIOS_END                0x00100000
> 
> 
> and I did try marking the ISA range RO in mark_rodata_ro() but the
> machine wouldn't boot after. So I'm guessing BIOS needs to write there
> some crap.

Yeah, that's what I also found out back then, the region needs to be WX.
So we can either leave with the warning, as we know it is harmless and
where it comes from or implement an exception in the checking code for
that region.

Regards,

	Joerg
