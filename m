Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E23AA6B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 18:27:21 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id l205so10122620vke.13
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 15:27:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p44sor4194500uag.226.2018.02.12.15.27.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Feb 2018 15:27:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <17e5b515-84c8-dca2-1695-cdf819834ea2@huawei.com>
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com> <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org> <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com> <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
 <CAFUG7CfrCpcbwgf5ixMC5EZZgiVVVp1NXhDHK1UoJJcC08R2qQ@mail.gmail.com>
 <8818bfd4-dd9f-f279-0432-69b59531bd41@huawei.com> <CAFUG7CeUhFcvA82uZ2ZH1j_6PM=aBo4XmYDN85pf8G0gPU44dg@mail.gmail.com>
 <17e5b515-84c8-dca2-1695-cdf819834ea2@huawei.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 12 Feb 2018 15:27:19 -0800
Message-ID: <CAGXu5j+LS1pgOOroi7Yxp2nh=DwtTnU3p-NZa6bQu_wkvvVkwg@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Boris Lukashev <blukashev@sempervictus.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Sun, Feb 4, 2018 at 7:05 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> On 04/02/18 00:29, Boris Lukashev wrote:
>> On Sat, Feb 3, 2018 at 3:32 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>
> [...]
>
>>> What you are suggesting, if I have understood it correctly, is that,
>>> when the pool is protected, the addresses already given out, will become
>>> traps that get resolved through a lookup table that is built based on
>>> the content of each allocation.
>>>
>>> That seems to generate a lot of overhead, not to mention the fact that
>>> it might not play very well with the MMU.
>>
>> That is effectively what i'm suggesting - as a form of protection for
>> consumers against direct reads of data which may have been corrupted
>> by some irrelevant means. In the context of pmalloc, it would probably
>> be a separate type of ro+verified pool
> ok, that seems more like an extension though.
>
> ATM I am having problems gaining traction to get even the basic merged :-)
>
> I would consider this as a possibility for future work, unless it is
> said that it's necessary for pmalloc to be accepted ...

I would agree: let's get basic functionality in first. Both
verification and the physmap part can be done separately, IMO.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
