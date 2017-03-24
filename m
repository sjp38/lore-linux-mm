Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 70E716B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 17:01:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id v2so849607lfi.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 14:01:19 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id c193si2107796lfg.31.2017.03.24.14.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 14:01:16 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id x137so184984lff.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 14:01:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170324120625.osoqp63x3sukijgj@node.shutemov.name>
References: <CANaxB-wtxWcHyOV1gJRjWvAi88FitcTYQzDUAvwV23YyQX0X+w@mail.gmail.com>
 <CANaxB-ygnT+HGy1FsEYb626209jvVzm3hr_ZXE=rOPomSbTm-g@mail.gmail.com> <20170324120625.osoqp63x3sukijgj@node.shutemov.name>
From: Andrei Vagin <avagin@gmail.com>
Date: Fri, 24 Mar 2017 14:01:14 -0700
Message-ID: <CANaxB-xwkvvFHL=gZjKktyd2YioCH3s5Di9o5vHkqKHju_tx0g@mail.gmail.com>
Subject: Re: linux-next: something wrong with 5-level paging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Mar 24, 2017 at 5:06 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Tue, Mar 21, 2017 at 03:03:20PM -0700, Andrei Vagin wrote:
>> Hi,
>>
>> I reproduced it locally. This kernel doesn't boot via kexec, but it
>> can boot if we set it via the qemu -kernel option. Then I tried to
>> boot the same kernel again via kexec and got a bug in dmesg:
>> [ 1252.014292] BUG: unable to handle kernel paging request at ffffd204f000f000
>> [ 1252.015093] IP: ident_pmd_init.isra.5+0x5a/0xb0
>> [ 1252.015636] PGD 0
>
> Sorry for this.
>
> http://lkml.kernel.org/r/20170324120458.nw3fwpmdptjtj5qb@node.shutemov.name

It works for me. Thanks.
https://travis-ci.org/avagin/linux/builds/214768664

>
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
