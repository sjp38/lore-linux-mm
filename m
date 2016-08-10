Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id A198F6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 08:05:08 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id u13so81559933uau.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:05:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d8si26607001qta.81.2016.08.10.05.05.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 05:05:07 -0700 (PDT)
Subject: Re: [PATCH v3] powerpc: Do not make the entire heap executable
References: <20160809190822.28856-1-dvlasenk@redhat.com>
 <87lh05tf30.fsf@concordia.ellerman.id.au>
From: Denys Vlasenko <dvlasenk@redhat.com>
Message-ID: <579d983b-6a6b-1a36-3ba6-ed8c6a756c5f@redhat.com>
Date: Wed, 10 Aug 2016 14:05:04 +0200
MIME-Version: 1.0
In-Reply-To: <87lh05tf30.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Kees Cook <keescook@chromium.org>, Oleg Nesterov <oleg@redhat.com>, Florian Weimer <fweimer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 08/10/2016 06:36 AM, Michael Ellerman wrote:
> Denys Vlasenko <dvlasenk@redhat.com> writes:
>
>> On 32-bit powerps the ELF PLT sections of binaries (built with --bss-plt,
>> or with a toolchain which defaults to it) look like this:
> ...
>>
>>  arch/powerpc/include/asm/page.h    | 10 +---------
>>  arch/powerpc/include/asm/page_32.h |  2 --
>>  arch/powerpc/include/asm/page_64.h |  4 ----
>>  fs/binfmt_elf.c                    | 34 ++++++++++++++++++++++++++--------
>>  include/linux/mm.h                 |  1 +
>>  mm/mmap.c                          | 20 +++++++++++++++-----
>>  6 files changed, 43 insertions(+), 28 deletions(-)
>
> What tree is this against?

Linus' tree from before August 2.
The "mm: refuse wrapped vm_brk requests" commit collided with my changes
I'll send patch v4 rebased to today's linus tree as soon as I finish testing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
