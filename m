Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 655D46B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:13:08 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x11so280794pgr.9
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 10:13:08 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b2si1569889pfm.409.2018.02.15.10.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 10:13:07 -0800 (PST)
Subject: Re: [PATCH 0/3] Use global pages with PTI
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <CA+55aFy8k_zSJ_ASyzkA9C-jLV4mZsHpv1sOxJ9qpvfS_P6eMg@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <648e1bf1-c03e-2f1a-8a08-3763e6211ad3@linux.intel.com>
Date: Thu, 15 Feb 2018 10:13:05 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFy8k_zSJ_ASyzkA9C-jLV4mZsHpv1sOxJ9qpvfS_P6eMg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>

On 02/15/2018 09:47 AM, Linus Torvalds wrote:
> On Thu, Feb 15, 2018 at 5:20 AM, Dave Hansen
> <dave.hansen@linux.intel.com> wrote:
>>
>> During the switch over to PTI, we seem to have lost our ability to have
>> GLOBAL mappings.
> 
> Oops. Odd, I have this distinct memory of somebody even _testing_ the
> global bit performance when I pointed out that we shouldn't just make
> the bit go away entirely.
> 
> [ goes back and looks at archives ]
> 
> Oh, that was in fact you who did that performance test.
...
> Did you perhaps re-run any benchmark numbers just to verify? Because
> it's always good to back up patches that should improve performance
> with actual numbers..

Nope, haven't done it yet, but I will.

I wanted to double-check that there was not a reason for doing the
global disabling other than the K8 TLB mismatch issues that Thomas fixed
a few weeks ago:

> commit 52994c256df36fda9a715697431cba9daecb6b11
> Author: Thomas Gleixner <tglx@linutronix.de>
> Date:   Wed Jan 3 15:57:59 2018 +0100
> 
>     x86/pti: Make sure the user/kernel PTEs match
>     
>     Meelis reported that his K8 Athlon64 emits MCE warnings when PTI is
>     enabled:
>     
>     [Hardware Error]: Error Addr: 0x0000ffff81e000e0
>     [Hardware Error]: MC1 Error: L1 TLB multimatch.
>     [Hardware Error]: cache level: L1, tx: INSN

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
