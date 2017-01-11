Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 034DC6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 14:39:03 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 101so1541509iom.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:39:02 -0800 (PST)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id w2si13065842ita.87.2017.01.11.11.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 11:39:02 -0800 (PST)
Received: by mail-io0-x244.google.com with SMTP id c80so186703iod.1
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:39:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170111193201.GF4895@node.shutemov.name>
References: <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
 <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com> <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
 <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
 <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com> <20170111142904.GD4895@node.shutemov.name>
 <CALCETrUn=KNdOnoRYd8GcnXPNDHAhGkaMaHRTAri4o92FSC1qg@mail.gmail.com>
 <20170111183750.GE4895@node.shutemov.name> <0a6f1ee4-e260-ae7b-3d39-c53f6bed8102@intel.com>
 <CALCETrXDbkotCZ1WEbhNeYGt0zyKT42agzsFxT2SZJ4wadEnQA@mail.gmail.com> <20170111193201.GF4895@node.shutemov.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 11 Jan 2017 11:39:01 -0800
Message-ID: <CA+55aFwQM7X+khpZB=8zKLH4ejavZc2LMH659f8tT-DxnQ3vEA@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 11, 2017 at 11:32 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Running legacy binary with full address space is valuable option.

I disagree.

It's simply not valuable enough to worry about. Especially when there
is a fairly trivial wrapper approach: just make a full-address-space
wrapper than acts as a binary loader (think "specialized ld.so").

Sure, the wrapper may be "fairly trivial" but not necessarily
pleasant: you have to parse ELF sections etc and basically load the
binary by hand. But there are libraries for that, and loading an ELF
executable isn't rocket surgery, it's just possibly tedious.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
