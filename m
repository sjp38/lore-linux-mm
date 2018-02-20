Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6DE86B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 12:07:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c37so4084023wra.5
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 09:07:40 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id f16si18418295wre.0.2018.02.20.09.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 09:07:39 -0800 (PST)
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
 <20180212165301.17933-2-igor.stoppa@huawei.com>
 <CAGXu5jJWLdsBr-6mXiFQprT-=h2qhhXAWRLQ+EaKKiubKOQOfw@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <daaee36a-e6c7-8fbf-b758-ecee5106da9a@huawei.com>
Date: Tue, 20 Feb 2018 19:07:12 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJWLdsBr-6mXiFQprT-=h2qhhXAWRLQ+EaKKiubKOQOfw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph
 Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 13/02/18 01:52, Kees Cook wrote:
> On Mon, Feb 12, 2018 at 8:52 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>> @@ -738,14 +1031,16 @@ EXPORT_SYMBOL(devm_gen_pool_create);
>>
>>  #ifdef CONFIG_OF
>>  /**
>> - * of_gen_pool_get - find a pool by phandle property
>> + * of_gen_pool_get() - find a pool by phandle property
>>   * @np: device node
>>   * @propname: property name containing phandle(s)
>>   * @index: index into the phandle array
>>   *
>> - * Returns the pool that contains the chunk starting at the physical
>> - * address of the device tree node pointed at by the phandle property,
>> - * or NULL if not found.
>> + * Return:
>> + * * pool address      - it contains the chunk starting at the physical
>> + *                       address of the device tree node pointed at by
>> + *                       the phandle property
>> + * * NULL              - otherwise
>>   */
>>  struct gen_pool *of_gen_pool_get(struct device_node *np,
>>         const char *propname, int index)
> 
> I wonder if this might be more readable by splitting the kernel-doc
> changes from the bitmap changes? I.e. fix all the kernel-doc in one
> patch, and in the following, make the bitmap changes. Maybe it's such
> a small part that it doesn't matter, though?

I had the same thought, but then I would have made most of the kerneldoc
changes to something that would be altered by the following patch,
because it would have made little sense to fix only those parts that
would have survived.

If it is really a problem to keep them together, I could put these
changes in a following patch. Would that be ok?

--
igor


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
