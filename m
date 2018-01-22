Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC96800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 15:51:33 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 32so10774771ioj.11
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:51:33 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y31si16478768ioe.346.2018.01.22.12.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 12:51:32 -0800 (PST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 704DA21787
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 20:51:31 +0000 (UTC)
Received: by mail-it0-f43.google.com with SMTP id x42so11447438ita.4
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 12:51:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <a7dd5f4e-5a63-3129-4b42-924ae2166d36@yandex-team.ru>
References: <150728974697.743944.5376694940133890044.stgit@buzz>
 <20171008091654.GA29939@infradead.org> <a7dd5f4e-5a63-3129-4b42-924ae2166d36@yandex-team.ru>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 22 Jan 2018 12:51:10 -0800
Message-ID: <CALCETrWcZCz18UQ_A-41HOOo-9Q7SdTA=bgpr98TJh3wbDG4wA@mail.gmail.com>
Subject: Re: [PATCH] vmalloc: add __alloc_vm_area() for optimizing vmap stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Dave Hansen <dave.hansen@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>

On Wed, Oct 11, 2017 at 6:32 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> On 08.10.2017 12:16, Christoph Hellwig wrote:
>>
>> This looks fine in general, but a few comments:
>>
>>   - can you split adding the new function from switching over the fork
>>     codeok
>
>
>>   - at least kasan and vmalloc_user/vmalloc_32_user use very similar
>>     patterns, can you switch them over as well?
>
>
> I don't see why VM_USERMAP cannot be set right at allocation.
>
> I'll add vm_flags argument to __vmalloc_node() and
> pass here VM_USERMAP from vmalloc_user/vmalloc_32_user
> in separate patch.
>
> KASAN is different: it allocates shadow area for area allocated for module.
> Pointer to module area must be pushed from module_alloc().
> This isn't worth optimization.
>
>>   - the new __alloc_vm_area looks very different from alloc_vm_area,
>>     maybe it needs a better name?  vmalloc_range_area for example?
>
>
> __vmalloc_area() is vacant - this most low-level, so I'll keep "__".
>
>>   - when you split an existing function please keep the more low-level
>>     function on top of the higher level one that calls it.ok

Did this ever get re-sent?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
