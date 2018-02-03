Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2DF6B0005
	for <linux-mm@kvack.org>; Sat,  3 Feb 2018 15:12:22 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m10so5819433pgq.1
        for <linux-mm@kvack.org>; Sat, 03 Feb 2018 12:12:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3-v6sor663216pld.18.2018.02.03.12.12.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Feb 2018 12:12:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com> <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org> <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com> <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
From: Boris Lukashev <blukashev@sempervictus.com>
Date: Sat, 3 Feb 2018 15:12:20 -0500
Message-ID: <CAFUG7CfrCpcbwgf5ixMC5EZZgiVVVp1NXhDHK1UoJJcC08R2qQ@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jerome Glisse <jglisse@redhat.com>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Sat, Feb 3, 2018 at 2:57 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>>> On Thu, 25 Jan 2018, Matthew Wilcox wrote:
>
>>>> It's worth having a discussion about whether we want the pmalloc API
>>>> or whether we want a slab-based API.
> I'd love to have some feedback specifically about the API.
>
> I have also some idea about userspace and how to extend the pmalloc
> concept to it:
>
> http://www.openwall.com/lists/kernel-hardening/2018/01/30/20
>
> I'll be AFK intermittently for about 2 weeks, so i might not be able to
> reply immediately, but from my perspective this would be just the
> beginning of a broader hardening of both kernel and userspace that I'd
> like to pursue.
>
> --
> igor

Regarding the notion of validated protected memory, is there a method
by which the resulting checksum could be used in a lookup
table/function to resolve the location of the protected data?
Effectively a hash table of protected allocations, with a benefit of
dedup since any data matching the same key would be the same data
(multiple identical cred structs being pushed around). Should leave
the resolver address/csum in recent memory to check against, right?

-- 
Boris Lukashev
Systems Architect
Semper Victus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
