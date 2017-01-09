Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF4F06B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 01:15:35 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d201so85668682qkg.2
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 22:15:35 -0800 (PST)
Received: from mail-qt0-x241.google.com (mail-qt0-x241.google.com. [2607:f8b0:400d:c0d::241])
        by mx.google.com with ESMTPS id c41si3965178qtc.80.2017.01.08.22.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Jan 2017 22:15:28 -0800 (PST)
Received: by mail-qt0-x241.google.com with SMTP id a29so13025012qtb.1
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 22:15:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4fbd559b-b4f2-2c89-3024-5d1137ff170d@linaro.org>
References: <20161216165437.21612-1-rrichter@cavium.com> <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org> <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CACJhumfqWkXXpbJomjJ1jM5B3kG+1Jk9EvGWR50_u-AO1ySXfg@mail.gmail.com> <4fbd559b-b4f2-2c89-3024-5d1137ff170d@linaro.org>
From: Prakash B <bjsprakash.linux@gmail.com>
Date: Mon, 9 Jan 2017 11:45:28 +0530
Message-ID: <CACJhumf4Ej4m5oPeVp1uKiYgk8LO-1W2L+ExhH6hti+yJXXnqA@mail.gmail.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Robert Richter <rrichter@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, David Daney <david.daney@cavium.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@armlinux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Morse <james.morse@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Thanks Hanjun ,


On Mon, Jan 9, 2017 at 10:39 AM, Hanjun Guo <hanjun.guo@linaro.org> wrote:
> Hi Prakash,
> I didn't test "cpuset01" on D05 but according to the test in
> Linaro, LTP full test is passed on D05 with Ard's 2 patches.
>
>>
>> Any idea what might be causing this issue.
>
>
> Since it's not happening on D05, maybe it's related to
> the firmware? (just a wild guess...)
>

 Used same firmware b/w 4.4 kernel and 4.9 (and   above kernels) .
Test passed wtih 4.4 kernel and didn't generated  any crashes or
dumps.

If there is more observation I will  send a  mail  or I will start a
separate mail thread.

Thanks,
Prakash B

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
