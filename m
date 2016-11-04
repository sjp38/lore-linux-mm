Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33CB9280260
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 18:03:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l124so25172324wml.4
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 15:03:29 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id l128si7490816wml.93.2016.11.04.15.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 15:03:27 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id p190so76980533wmp.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 15:03:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+uQqgZSv3fyo+_5z7u9CC=2KjtcAiP6bQkzi9ZK6XLww@mail.gmail.com>
References: <20161003161322.3835-1-dvlasenk@redhat.com> <CAGXu5j+haCUW_AEPLPcVGtrnv4ojQ79FDpspUurYJSX_-TXeow@mail.gmail.com>
 <877f9p55lu.fsf@concordia.ellerman.id.au> <CAGXu5jJ3PpvNBYyBWa_M8ELLPuJOcJt-KuH0uRK66peJM_CnSg@mail.gmail.com>
 <20161020224521.GA24970@obsidianresearch.com> <CAGXu5j+uQqgZSv3fyo+_5z7u9CC=2KjtcAiP6bQkzi9ZK6XLww@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 4 Nov 2016 16:03:26 -0600
Message-ID: <CAGXu5jKsx8krJue8XZeYjz+ajvmkf2j2ZhdLz_hgGCbPiSS59w@mail.gmail.com>
Subject: Re: [PATCH v6] powerpc: Do not make the entire heap executable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi,

Jason just reminded me about this patch. :)

Denys, can you resend a v7 with all the Acked/Reviewed/Tested-bys
added and send it To: akpm, with everyone else (and lkml) in CC? That
should be the easiest way for Andrew to pick it up.

Thanks!

-Kees


On Mon, Oct 24, 2016 at 5:17 PM, Kees Cook <keescook@chromium.org> wrote:
> On Thu, Oct 20, 2016 at 3:45 PM, Jason Gunthorpe
> <jgunthorpe@obsidianresearch.com> wrote:
>> On Tue, Oct 04, 2016 at 09:54:12AM -0700, Kees Cook wrote:
>>> On Mon, Oct 3, 2016 at 5:18 PM, Michael Ellerman <mpe@ellerman.id.au> wrote:
>>> > Kees Cook <keescook@chromium.org> writes:
>>> >
>>> >> On Mon, Oct 3, 2016 at 9:13 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
>>> >>> On 32-bit powerpc the ELF PLT sections of binaries (built with --bss-plt,
>>> >>> or with a toolchain which defaults to it) look like this:
>>> > ...
>>> >>>
>>> >>> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>>> >>> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
>>> >>> Acked-by: Kees Cook <keescook@chromium.org>
>>> >>> Acked-by: Michael Ellerman <mpe@ellerman.id.au>
>>> >>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>>> >>> CC: Paul Mackerras <paulus@samba.org>
>>> >>> CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>> >>> CC: Kees Cook <keescook@chromium.org>
>>> >>> CC: Oleg Nesterov <oleg@redhat.com>
>>> >>> CC: Michael Ellerman <mpe@ellerman.id.au>
>>> >>> CC: Florian Weimer <fweimer@redhat.com>
>>> >>> CC: linux-mm@kvack.org
>>> >>> CC: linuxppc-dev@lists.ozlabs.org
>>> >>> CC: linux-kernel@vger.kernel.org
>>> >>> Changes since v5:
>>> >>> * made do_brk_flags() error out if any bits other than VM_EXEC are set.
>>> >>>   (Kees Cook: "With this, I'd be happy to Ack.")
>>> >>>   See https://patchwork.ozlabs.org/patch/661595/
>>> >>
>>> >> Excellent, thanks for the v6! Should this go via the ppc tree or the -mm tree?
>>> >
>>> > -mm would be best, given the diffstat I think it's less likely to
>>> >  conflict if it goes via -mm.
>>>
>>> Okay, excellent. Andrew, do you have this already in email? I think
>>> you weren't on the explicit CC from the v6...
>>
>> FWIW (and ping),
>>
>> Tested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>>
>> On ARM32 (kirkwood) and PPC32 (405)
>>
>> For reference, here is the patchwork URL:
>>
>> https://patchwork.ozlabs.org/patch/677753/
>
> Hi Andrew,
>
> Can you pick this up?
>
> Thanks!
>
> -Kees
>
> --
> Kees Cook
> Nexus Security



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
