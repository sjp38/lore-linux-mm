Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 199016B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 14:03:17 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id y18so62275604itc.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:03:17 -0700 (PDT)
Received: from mail-it0-x230.google.com (mail-it0-x230.google.com. [2607:f8b0:4001:c0b::230])
        by mx.google.com with ESMTPS id y67si4178068ita.99.2017.03.16.11.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 11:03:08 -0700 (PDT)
Received: by mail-it0-x230.google.com with SMTP id w124so5831853itb.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:03:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
References: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 16 Mar 2017 11:03:07 -0700
Message-ID: <CA+55aFxh7E4OzCUgN-42jYzQGXCZEUoT8dZfnmkGTXi6fxrbmw@mail.gmail.com>
Subject: Re: [PATCH 0/7] Switch x86 to generic get_user_pages_fast() implementation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Mar 16, 2017 at 8:26 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> The patcheset generalize mm/gup.c implementation of get_user_pages_fast()
> to be usable for x86 and switches x86 over.

Thanks for doing this, it looks good and removes more lines than it adds.

And despite removing lines, it should make it easier for other
architectures to support devmap if they ever want to. I hadn't even
noticed that difference in the GUP implementations.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
