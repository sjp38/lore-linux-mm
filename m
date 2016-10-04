Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 596E86B0038
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 20:18:43 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id l13so279387588itl.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 17:18:43 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id l137si1654161ioe.217.2016.10.03.17.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 17:18:42 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v6] powerpc: Do not make the entire heap executable
In-Reply-To: <CAGXu5j+haCUW_AEPLPcVGtrnv4ojQ79FDpspUurYJSX_-TXeow@mail.gmail.com>
References: <20161003161322.3835-1-dvlasenk@redhat.com> <CAGXu5j+haCUW_AEPLPcVGtrnv4ojQ79FDpspUurYJSX_-TXeow@mail.gmail.com>
Date: Tue, 04 Oct 2016 11:18:37 +1100
Message-ID: <877f9p55lu.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Denys Vlasenko <dvlasenk@redhat.com>
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Kees Cook <keescook@chromium.org> writes:

> On Mon, Oct 3, 2016 at 9:13 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
>> On 32-bit powerpc the ELF PLT sections of binaries (built with --bss-plt,
>> or with a toolchain which defaults to it) look like this:
...
>>
>> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
>> Acked-by: Kees Cook <keescook@chromium.org>
>> Acked-by: Michael Ellerman <mpe@ellerman.id.au>
>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> CC: Paul Mackerras <paulus@samba.org>
>> CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> CC: Kees Cook <keescook@chromium.org>
>> CC: Oleg Nesterov <oleg@redhat.com>
>> CC: Michael Ellerman <mpe@ellerman.id.au>
>> CC: Florian Weimer <fweimer@redhat.com>
>> CC: linux-mm@kvack.org
>> CC: linuxppc-dev@lists.ozlabs.org
>> CC: linux-kernel@vger.kernel.org
>> ---
>> Changes since v5:
>> * made do_brk_flags() error out if any bits other than VM_EXEC are set.
>>   (Kees Cook: "With this, I'd be happy to Ack.")
>>   See https://patchwork.ozlabs.org/patch/661595/
>
> Excellent, thanks for the v6! Should this go via the ppc tree or the -mm tree?

-mm would be best, given the diffstat I think it's less likely to
 conflict if it goes via -mm.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
