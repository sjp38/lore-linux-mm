Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4A676B0271
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 03:48:41 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id a77-v6so7437743wrc.16
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 00:48:41 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id w8-v6si3069639wro.157.2018.10.04.00.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 00:48:40 -0700 (PDT)
Date: Thu, 4 Oct 2018 09:48:27 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004074827.GA1864@zn.tnic>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
 <18bf13a4-2853-358e-594f-27533193757c@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <18bf13a4-2853-358e-594f-27533193757c@molgen.mpg.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Thu, Oct 04, 2018 at 05:11:17AM +0200, Paul Menzel wrote:
> Thank you for looking into this. On what board are you able to reproduce
> this? Do you build for 32-bit or 64-bit?

32-bit partition on an AMD F14h laptop.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
