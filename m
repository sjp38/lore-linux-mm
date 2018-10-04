Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50B4F6B026F
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:49:49 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id z23-v6so6247303wma.2
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:49:49 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id 82-v6si3542939wmr.108.2018.10.04.01.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:49:48 -0700 (PDT)
Date: Thu, 4 Oct 2018 10:49:46 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004084946.GD1864@zn.tnic>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
 <20181004080321.GA3630@8bytes.org>
 <20181004081429.GB1864@zn.tnic>
 <6cbb9135-7e89-748f-1d55-ac105a9f8091@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <6cbb9135-7e89-748f-1d55-ac105a9f8091@molgen.mpg.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: =?utf-8?B?SsO2cmcgUsO2ZGVs?= <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Thu, Oct 04, 2018 at 10:40:49AM +0200, Paul Menzel wrote:
> Do you have a commit, I could test.

Not yet but I have a question for you: why are you running 32-bit and
haven't moved to 64-bit already?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
