Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7986B1B4E
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 17:57:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n144-v6so928778itg.2
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 14:57:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k78-v6sor3651583ioe.196.2018.08.20.14.57.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 14:57:50 -0700 (PDT)
MIME-Version: 1.0
References: <20180820203705.16212-1-andi@firstfloor.org> <20180820203705.16212-2-andi@firstfloor.org>
In-Reply-To: <20180820203705.16212-2-andi@firstfloor.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 20 Aug 2018 14:57:39 -0700
Message-ID: <CA+55aFyo_MFz2Qg3pEbLMf3zhvAQbpZf3mQf98bTRJx28drbeQ@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Simplify p[g4um]d_page() macros
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: stable <stable@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Brijesh Singh <brijesh.singh@amd.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Larry Woodman <lwoodman@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Toshi Kani <toshi.kani@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, KVM list <kvm@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-efi <linux-efi@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>

On Mon, Aug 20, 2018 at 1:37 PM Andi Kleen <andi@firstfloor.org> wrote:
>
> From: Andi Kleen <ak@linux.intel.com>
>
> Create a pgd_pfn() macro similar to the p[4um]d_pfn() macros and then
> use the p[g4um]d_pfn() macros in the p[g4um]d_page() macros instead of
> duplicating the code.

When doing backports, _please_ explicitly specify which commit this is
upstream too.

Also, the original upstream patch is credited to Tom Lendacky.

Or is there something I'm not seeing, and this is different from
commit fd7e315988b7 ("x86/mm: Simplify p[g4um]d_page() macros")?

               Linus
