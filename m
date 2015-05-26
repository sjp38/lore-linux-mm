Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 069716B0121
	for <linux-mm@kvack.org>; Tue, 26 May 2015 10:22:19 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so91884886pdf.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 07:22:18 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id fe7si21225170pab.94.2015.05.26.07.22.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 26 May 2015 07:22:18 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOY00L2WNX1L160@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 26 May 2015 15:22:13 +0100 (BST)
Message-id: <55648193.3030003@samsung.com>
Date: Tue, 26 May 2015 17:22:11 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <CACRpkda3Pe9L14_iyKEfeCx1F3XJSLbz_OVHLxX0Lzy9Gt9t9Q@mail.gmail.com>
 <55647F57.8010008@samsung.com>
In-reply-to: <55647F57.8010008@samsung.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

On 05/26/2015 05:12 PM, Andrey Ryabinin wrote:
> On 05/26/2015 04:35 PM, Linus Walleij wrote:
>> I wonder were the problem lies, any hints where to start looking
>> to fix this?
>>
> 
> I suspect that your compiler lack -fsantize=kernel-address support.
> It seems that GCC 4.9.2 doesn't supports -fsanitize=address/kernel-address on aarch64.
> 

In that case you should get something like this, during kernel build:
	scripts/Makefile.kasan:17: Cannot use CONFIG_KASAN: -fsanitize=kernel-address is not supported by compiler


Also you may check you gcc by compiling simple program:
$ cat test.c
void main(void) {
}

$ gcc -fsanitize=kernel-address test.c


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
