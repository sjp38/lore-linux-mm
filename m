Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 85DA76B0007
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 10:05:36 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id j13so6363159wmh.3
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 07:05:36 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id r5si4114270wma.276.2018.02.04.07.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Feb 2018 07:05:35 -0800 (PST)
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
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <17e5b515-84c8-dca2-1695-cdf819834ea2@huawei.com>
Date: Sun, 4 Feb 2018 17:05:25 +0200
MIME-Version: 1.0
In-Reply-To: <CAFUG7CeUhFcvA82uZ2ZH1j_6PM=aBo4XmYDN85pf8G0gPU44dg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Lukashev <blukashev@sempervictus.com>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jerome Glisse <jglisse@redhat.com>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel
 Hardening <kernel-hardening@lists.openwall.com>

On 04/02/18 00:29, Boris Lukashev wrote:
> On Sat, Feb 3, 2018 at 3:32 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:

[...]

>> What you are suggesting, if I have understood it correctly, is that,
>> when the pool is protected, the addresses already given out, will become
>> traps that get resolved through a lookup table that is built based on
>> the content of each allocation.
>>
>> That seems to generate a lot of overhead, not to mention the fact that
>> it might not play very well with the MMU.
> 
> That is effectively what i'm suggesting - as a form of protection for
> consumers against direct reads of data which may have been corrupted
> by some irrelevant means. In the context of pmalloc, it would probably
> be a separate type of ro+verified pool
ok, that seems more like an extension though.

ATM I am having problems gaining traction to get even the basic merged :-)

I would consider this as a possibility for future work, unless it is
said that it's necessary for pmalloc to be accepted ...

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
