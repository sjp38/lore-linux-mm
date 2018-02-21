Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2BA06B0005
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:29:08 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id m142so1637143vkf.23
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:29:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y189sor2788419vky.23.2018.02.21.14.29.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 14:29:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <daaee36a-e6c7-8fbf-b758-ecee5106da9a@huawei.com>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <20180212165301.17933-2-igor.stoppa@huawei.com> <CAGXu5jJWLdsBr-6mXiFQprT-=h2qhhXAWRLQ+EaKKiubKOQOfw@mail.gmail.com>
 <daaee36a-e6c7-8fbf-b758-ecee5106da9a@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 21 Feb 2018 14:29:06 -0800
Message-ID: <CAGXu5j+zRQfxRXoSC5G8EjeSkPkpeMxfedJbHEgFyYcyXWmW9w@mail.gmail.com>
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Tue, Feb 20, 2018 at 9:07 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> On 13/02/18 01:52, Kees Cook wrote:
>> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>>> @@ -738,14 +1031,16 @@ EXPORT_SYMBOL(devm_gen_pool_create);
>>>
>>>  #ifdef CONFIG_OF
>>>  /**
>>> - * of_gen_pool_get - find a pool by phandle property
>>> + * of_gen_pool_get() - find a pool by phandle property
>>>   * @np: device node
>>>   * @propname: property name containing phandle(s)
>>>   * @index: index into the phandle array
>>>   *
>>> - * Returns the pool that contains the chunk starting at the physical
>>> - * address of the device tree node pointed at by the phandle property,
>>> - * or NULL if not found.
>>> + * Return:
>>> + * * pool address      - it contains the chunk starting at the physical
>>> + *                       address of the device tree node pointed at by
>>> + *                       the phandle property
>>> + * * NULL              - otherwise
>>>   */
>>>  struct gen_pool *of_gen_pool_get(struct device_node *np,
>>>         const char *propname, int index)
>>
>> I wonder if this might be more readable by splitting the kernel-doc
>> changes from the bitmap changes? I.e. fix all the kernel-doc in one
>> patch, and in the following, make the bitmap changes. Maybe it's such
>> a small part that it doesn't matter, though?
>
> I had the same thought, but then I would have made most of the kerneldoc
> changes to something that would be altered by the following patch,
> because it would have made little sense to fix only those parts that
> would have survived.
>
> If it is really a problem to keep them together, I could put these
> changes in a following patch. Would that be ok?

Hmmm... I think keeping it as-is would be better than a trailing
docs-only patch. Maybe Jon has an opinion?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
