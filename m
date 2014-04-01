Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2091B6B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 13:27:49 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id hl10so1595463igb.12
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 10:27:48 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id i17si10241420igh.21.2014.04.01.10.27.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 10:27:47 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so9560932iec.19
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 10:27:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140401175947.5b5a3298@alan.etchedpixels.co.uk>
References: <20140331211607.26784.43976.stgit@zurg>
	<20140401175947.5b5a3298@alan.etchedpixels.co.uk>
Date: Tue, 1 Apr 2014 21:27:47 +0400
Message-ID: <CALYGNiONACddsH_6uaG5QyaWRaZ_5ZH0atZJyZVD=DowiKLJcw@mail.gmail.com>
Subject: Re: [PATCH RFC] drivers/char/mem: byte generating devices and
 poisoned mappings
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Yury Gribov <y.gribov@samsung.com>, Alexandr Andreev <aandreev@parallels.com>, Vassili Karpov <av1474@comtv.ru>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Apr 1, 2014 at 8:59 PM, One Thousand Gnomes
<gnomes@lxorguk.ukuu.org.uk> wrote:
> On Tue, 01 Apr 2014 01:16:07 +0400
> Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
>> This patch adds 256 virtual character devices: /dev/byte0, ..., /dev/byte255.
>> Each works like /dev/zero but generates memory filled with particular byte.
>
> More kernel code for an ultra-obscure corner case that can be done in
> user space
>
> I don't see the point

True. That was a long-planned joke.
But at the final moment I've found practical usage for it and overall
design became not such funny.

Currently I'm thinking about single-device model proposed by Kirill.

Let's call it /dev/poison. Application can open it, write a poison (up
to a page size) and after that this instance will generate pages
filled with this pattern. I don't see how this can be done in
userspace without major memory/cpu overhead caused by initial memset.

Default poison might be for example 0xff, so it still will be useful for 'dd'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
