Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BCB7680FC1
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:22:09 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id q14so29343849uaq.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:22:09 -0800 (PST)
Received: from mail-ua0-x230.google.com (mail-ua0-x230.google.com. [2607:f8b0:400c:c08::230])
        by mx.google.com with ESMTPS id a72si3372503vke.221.2017.02.17.09.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 09:22:08 -0800 (PST)
Received: by mail-ua0-x230.google.com with SMTP id y9so34230885uae.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:22:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ae15457f-731d-bb1b-c60d-14d641c265f0@intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com> <ae15457f-731d-bb1b-c60d-14d641c265f0@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 17 Feb 2017 09:21:47 -0800
Message-ID: <CALCETrU957t7RQOAUJKWdjcA8t2ScWGkrnou2+cHksetC9aN=A@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Feb 17, 2017 at 9:19 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 02/17/2017 06:13 AM, Kirill A. Shutemov wrote:
>> +/*
>> + * Default maximum virtual address. This is required for
>> + * compatibility with applications that assumes 47-bit VA.
>> + * The limit can be changed with prctl(PR_SET_MAX_VADDR).
>> + */
>> +#define MAX_VADDR_DEFAULT    ((1UL << 47) - PAGE_SIZE)
>
> This is a bit goofy.  It's not the largest virtual adddress that can be
> accessed, but the beginning of the last page.

No, it really is the limit.  We don't allow user code to map the last
page because ti would be a root hole due to SYSRET.  Thanks, Intel.
See the comment near TASK_SIZE_MAX IIRC.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
