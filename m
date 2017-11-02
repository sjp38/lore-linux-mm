Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 029816B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 12:36:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j3so119609pga.5
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 09:36:40 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id y1si4075365pfy.314.2017.11.02.09.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 09:36:39 -0700 (PDT)
Subject: Re: KAISER memory layout (Re: [PATCH 06/23] x86, kaiser: introduce
 user-mapped percpu areas)
References: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <606e6084-baf7-fc45-b2f3-92b78ea7fcad@linux.intel.com>
Date: Thu, 2 Nov 2017 09:36:37 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>

On 11/02/2017 02:41 AM, Andy Lutomirski wrote:
> 
>  - The GDT array.
>  - The IDT.
>  - The vsyscall page.  We can make this be _PAGE_USER.
>  - The TSS.
>  - The per-cpu entry stack.  Let's make it one page with guard pages
> on either side.  This can replace rsp_scratch.
>  - cpu_current_top_of_stack.  This could be in the same page as the TSS.
>  - The entry text.
>  - The percpu IST (aka "EXCEPTION") stacks.
> 
> That's it.

The PEBS/BTS buffers need it too, I think:

https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/commit/?h=kaiser-414rc6-20171031&id=97a334906d7853a8109b295ef94f3991418d0c07

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
