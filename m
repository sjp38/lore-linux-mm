Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE39D8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 15:22:12 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id j5so30811367qtk.11
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 12:22:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u9sor35533132qtq.66.2018.12.29.12.22.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 12:22:11 -0800 (PST)
Subject: Re: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
References: <20181226023534.64048-1-cai@lca.pw>
 <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
 <403405f1-b702-2feb-4616-35fc3dc3133e@lca.pw>
 <CAKv+Gu_e=NkKZ5C+KzBmgg2VMXNKPqXcPON8heRd0F_iW+aaEQ@mail.gmail.com>
 <20181227190456.0f21d511ef71f1b455403f2a@linux-foundation.org>
 <CAKv+Gu98AOB2LfQGMUHNc_B0MBvd3gATvtPypQaV1vgTcf87ww@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <70d2a620-d9d8-f351-78fb-1135d264d824@lca.pw>
Date: Sat, 29 Dec 2018 15:22:09 -0500
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu98AOB2LfQGMUHNc_B0MBvd3gATvtPypQaV1vgTcf87ww@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, linux-efi <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 12/29/18 4:17 AM, Ard Biesheuvel wrote:
> On Fri, 28 Dec 2018 at 04:04, Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>> On Wed, 26 Dec 2018 16:31:59 +0100 Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
>>
>>> Please stop sending EFI patches if you can't be bothered to
>>> test/reproduce against the EFI tree.
>>
>> um, sorry, but that's a bit strong.  Finding (let alone fixing) a bug
>> in EFI is a great contribution (thanks!) and the EFI maintainers are
>> perfectly capable of reviewing and testing the proposed fix.  Or of
>> fixing the bug by other means.
>>
> 
> Qian did spot some issues recently, which was really helpful. But I
> really think that reporting all issues you find against the -mmotm
> tree because that happens to be your preferred tree for development is
> not the correct approach.
> 
>> Let's not beat people up for helping us in a less-than-perfect way, no?
> 
> Fair enough. But asking people to ensure that an issue they found
> actually exists on the subsystem tree in question is not that much to
> ask, is it?

It is not too much to ask to test on EFI subsystem tree only for this patch, but
if every maintainer asked for the same thing to test each subsystem tree after
found a bug even a trivial one in -mmotm or linux-next, it then become an issue.

There are people genuinely interested in the kernel in general rather than focus
on a few subsystems (yet). There are many subsystem git trees out there. It at
least needs to figure out which branch to test and adjust the config file
accordingly. Those subsystem trees usually are not well-documented like
linux-next or -mmotm trees. Then, they may need to deal with the subsystem
tree-specific issues.

Those people may just better switch to use mainline instead where they don't
need to bother testing the subsystem tree for every single patch. However, that
will cause delay in fixing those issues because mainline is usually a bit lag
behind the development.
