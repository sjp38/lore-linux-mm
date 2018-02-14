Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90B206B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:06:11 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id l18so9426369otd.1
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:06:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g88sor6261340otg.251.2018.02.14.11.06.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 11:06:10 -0800 (PST)
Subject: arm64 physmap (was Re: [kernel-hardening] [PATCH 4/6] Protectable
 Memory)
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
 <414027d3-dd73-cf11-dc2a-e8c124591646@redhat.com>
 <CAGXu5j++igQD4tMh0J8nZ9jNji5mU16C7OygFJ5Td+Bq-KSMgw@mail.gmail.com>
 <CAG48ez1utN_vwHUwk=BU6zM4Wa_53TPu8rm9JuTtY-vGP0Shqw@mail.gmail.com>
 <f4226a44-92fd-8ead-b458-7551ba82f96d@redhat.com>
 <CAGXu5j+zOCLerneUt2b-tvyLLg7fEbr9B0YYow-4DH6oV-nnCw@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <2f23544a-bd24-1e71-967b-e8d1cf5a20a3@redhat.com>
Date: Wed, 14 Feb 2018 11:06:06 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+zOCLerneUt2b-tvyLLg7fEbr9B0YYow-4DH6oV-nnCw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jann Horn <jannh@google.com>, Igor Stoppa <igor.stoppa@huawei.com>, Boris Lukashev <blukashev@sempervictus.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>

On 02/13/2018 01:43 PM, Kees Cook wrote:
> On Tue, Feb 13, 2018 at 8:09 AM, Laura Abbott <labbott@redhat.com> wrote:
>> No, arm64 doesn't fixup the aliases, mostly because arm64 uses larger
>> page sizes which can't be broken down at runtime. CONFIG_PAGE_POISONING
>> does use 4K pages which could be adjusted at runtime. So yes, you are
>> right we would have physmap exposure on arm64 as well.
> 
> Errr, so that means even modules and kernel code are writable via the
> arm64 physmap? That seems extraordinarily bad. :(
> 
> -Kees
> 

(adding linux-arm-kernel and changing the subject)

Kernel code should be fine, if it isn't that is a bug that should be
fixed. Modules yes are not fully protected. The conclusion from past
experience has been that we cannot safely break down larger page sizes
at runtime like x86 does. We could theoretically
add support for fixing up the alias if PAGE_POISONING is enabled but
I don't know who would actually use that in production. Performance
is very poor at that point.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
