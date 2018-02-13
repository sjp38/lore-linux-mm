Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87C466B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 19:40:45 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 91so10028555otl.23
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 16:40:45 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a16sor3307496ota.97.2018.02.12.16.40.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Feb 2018 16:40:44 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org>
 <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
 <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
 <CAFUG7CfrCpcbwgf5ixMC5EZZgiVVVp1NXhDHK1UoJJcC08R2qQ@mail.gmail.com>
 <8818bfd4-dd9f-f279-0432-69b59531bd41@huawei.com>
 <CAFUG7CeUhFcvA82uZ2ZH1j_6PM=aBo4XmYDN85pf8G0gPU44dg@mail.gmail.com>
 <17e5b515-84c8-dca2-1695-cdf819834ea2@huawei.com>
 <CAGXu5j+LS1pgOOroi7Yxp2nh=DwtTnU3p-NZa6bQu_wkvvVkwg@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <414027d3-dd73-cf11-dc2a-e8c124591646@redhat.com>
Date: Mon, 12 Feb 2018 16:40:40 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+LS1pgOOroi7Yxp2nh=DwtTnU3p-NZa6bQu_wkvvVkwg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Igor Stoppa <igor.stoppa@huawei.com>
Cc: Boris Lukashev <blukashev@sempervictus.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 02/12/2018 03:27 PM, Kees Cook wrote:
> On Sun, Feb 4, 2018 at 7:05 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>> On 04/02/18 00:29, Boris Lukashev wrote:
>>> On Sat, Feb 3, 2018 at 3:32 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>>
>> [...]
>>
>>>> What you are suggesting, if I have understood it correctly, is that,
>>>> when the pool is protected, the addresses already given out, will become
>>>> traps that get resolved through a lookup table that is built based on
>>>> the content of each allocation.
>>>>
>>>> That seems to generate a lot of overhead, not to mention the fact that
>>>> it might not play very well with the MMU.
>>>
>>> That is effectively what i'm suggesting - as a form of protection for
>>> consumers against direct reads of data which may have been corrupted
>>> by some irrelevant means. In the context of pmalloc, it would probably
>>> be a separate type of ro+verified pool
>> ok, that seems more like an extension though.
>>
>> ATM I am having problems gaining traction to get even the basic merged :-)
>>
>> I would consider this as a possibility for future work, unless it is
>> said that it's necessary for pmalloc to be accepted ...
> 
> I would agree: let's get basic functionality in first. Both
> verification and the physmap part can be done separately, IMO.

Skipping over physmap leaves a pretty big area of exposure that could
be difficult to solve later. I appreciate this might block basic
functionality but I don't think we should just gloss over it without
at least some idea of what we would do.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
