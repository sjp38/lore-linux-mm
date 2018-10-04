Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF7F76B0006
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 06:54:51 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 88-v6so7751115wrp.21
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 03:54:51 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id 33-v6si3947446wrp.167.2018.10.04.03.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 03:54:50 -0700 (PDT)
Date: Thu, 4 Oct 2018 12:54:43 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004105443.GH1864@zn.tnic>
References: <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
 <20181004080321.GA3630@8bytes.org>
 <20181004081429.GB1864@zn.tnic>
 <6cbb9135-7e89-748f-1d55-ac105a9f8091@molgen.mpg.de>
 <20181004084946.GD1864@zn.tnic>
 <bdc5d224-91d6-eeee-c334-4b76efb56cac@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <bdc5d224-91d6-eeee-c334-4b76efb56cac@molgen.mpg.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: =?utf-8?B?SsO2cmcgUsO2ZGVs?= <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Thu, Oct 04, 2018 at 10:59:18AM +0200, Paul Menzel wrote:
> I meant just the test you did.

https://lkml.kernel.org/r/20181003212255.GB28361@zn.tnic

> The SSD is also used in the Lenovo X60 and T60, which are
> 32-bit systems.

And what exactly is the problem when you access it on a 64-bit OS?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
