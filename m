Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0005C6B0253
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 20:08:51 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id xk3so8853433obc.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 17:08:51 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id q8si5343000obk.65.2016.02.02.17.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 17:08:51 -0800 (PST)
Received: by mail-ob0-x22a.google.com with SMTP id ba1so8664153obb.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 17:08:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6d5ca2f80f3da2b898ac2501175ac170d746a388.1454455138.git.tony.luck@intel.com>
References: <cover.1454455138.git.tony.luck@intel.com> <6d5ca2f80f3da2b898ac2501175ac170d746a388.1454455138.git.tony.luck@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 2 Feb 2016 17:08:31 -0800
Message-ID: <CALCETrUEvnwrUs2e4VJ2bOThWGPoypQAnTyZFA1F=oQzdfsodA@mail.gmail.com>
Subject: Re: [PATCH v9 2/4] x86, mce: Check for faults tagged in
 EXTABLE_CLASS_FAULT exception table entries
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Brian Gerst <brgerst@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Thu, Dec 31, 2015 at 11:40 AM, Tony Luck <tony.luck@intel.com> wrote:
> Extend the severity checking code to add a new context IN_KERN_RECOV
> which is used to indicate that the machine check was triggered by code
> in the kernel with a EXTABLE_CLASS_FAULT fixup entry.

I think that the EXTABLE_CLASS_FAULT references no longer match the code.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
