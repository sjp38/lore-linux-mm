Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFD16B0261
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 15:44:45 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id m60so61179545uam.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:44:45 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id s32si5069175uas.142.2016.07.29.12.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 12:44:44 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id s189so61513697vkh.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:44:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <579B977B.7090609@intel.com>
References: <20160729163009.5EC1D38C@viggo.jf.intel.com> <20160729163021.F3C25D4A@viggo.jf.intel.com>
 <CALCETrWMg=+YSi7Az+gw9B59OoAEkOd=znpr7+++5=UUg6DThw@mail.gmail.com> <579B977B.7090609@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 29 Jul 2016 12:44:24 -0700
Message-ID: <CALCETrVW0taeuBjha1DEdafM5zZgbAHo=x1AJm=BafTEr++8Vg@mail.gmail.com>
Subject: Re: [PATCH 08/10] x86, pkeys: default to a restrictive init PKRU
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>

On Fri, Jul 29, 2016 at 10:50 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 07/29/2016 10:29 AM, Andy Lutomirski wrote:
>>> > In the end, this ensures that threads which do not know how to
>>> > manage their own pkey rights can not do damage to data which is
>>> > pkey-protected.
>> I think you missed the fpu__clear() caller in kernel/fpu/signal.c.
>>
>> ISTM it might be more comprehensible to change fpu__clear in general
>> and then special case things you want to behave differently.
>
> The code actually already patched the generic fpu__clear():
>
>         fpu__clear() ->
>         copy_init_fpstate_to_fpregs() ->
>         copy_init_pkru_to_fpregs()
>
> So I think it hit the case you are talking about.

Whoops, missed that.

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
