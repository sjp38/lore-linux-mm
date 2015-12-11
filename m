Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id D23E16B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:08:25 -0500 (EST)
Received: by oifz134 with SMTP id z134so308059oif.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:08:25 -0800 (PST)
Received: from mail-ob0-x229.google.com (mail-ob0-x229.google.com. [2607:f8b0:4003:c01::229])
        by mx.google.com with ESMTPS id d66si4406312oia.2.2015.12.11.12.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 12:08:25 -0800 (PST)
Received: by obciw8 with SMTP id iw8so91365461obc.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:08:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <e8029c58c7d4b5094ec274c78dee01d390317d4d.1449861203.git.tony.luck@intel.com>
References: <cover.1449861203.git.tony.luck@intel.com> <e8029c58c7d4b5094ec274c78dee01d390317d4d.1449861203.git.tony.luck@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Dec 2015 12:08:05 -0800
Message-ID: <CALCETrUwEeuZV26uWs4_T_NEBrRru3ROqK3DAtr1_7BZ39S_Yw@mail.gmail.com>
Subject: Re: [PATCHV2 2/3] x86, ras: Extend machine check recovery code to
 annotated ring0 areas
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Thu, Dec 10, 2015 at 4:14 PM, Tony Luck <tony.luck@intel.com> wrote:
> Extend the severity checking code to add a new context IN_KERN_RECOV
> which is used to indicate that the machine check was triggered by code
> in the kernel with a fixup entry.
>
> Add code to check for this situation and respond by altering the return
> IP to the fixup address and changing the regs->ax so that the recovery
> code knows the physical address of the error. Note that we also set bit
> 63 because 0x0 is a legal physical address.
>
> Major re-work to the tail code in do_machine_check() to make all this
> readable/maintainable. One functional change is that tolerant=3 no longer
> stops recovery actions. Revert to only skipping sending SIGBUS to the
> current process.

This is IMO much, much nicer than the old code.  Thanks!

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
