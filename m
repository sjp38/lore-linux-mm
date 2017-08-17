Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98AA26B02B4
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 00:58:28 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p62so6821264oih.12
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 21:58:28 -0700 (PDT)
Received: from mail-it0-x22d.google.com (mail-it0-x22d.google.com. [2607:f8b0:4001:c0b::22d])
        by mx.google.com with ESMTPS id b62si1938706oih.472.2017.08.16.21.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 21:58:27 -0700 (PDT)
Received: by mail-it0-x22d.google.com with SMTP id 77so26582324itj.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 21:58:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFJ0LnHdAwAHJipwqOHzdLktCL+Ttdywuogk0ORHqn7eauRLkA@mail.gmail.com>
References: <20170816224650.1089-1-labbott@redhat.com> <20170816224650.1089-3-labbott@redhat.com>
 <CAFJ0LnHdAwAHJipwqOHzdLktCL+Ttdywuogk0ORHqn7eauRLkA@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 16 Aug 2017 21:58:26 -0700
Message-ID: <CAGXu5jLyegoCA4cBDyOWvcsV3_wE8BBFRnuhkbORdFHTswGpoA@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCHv2 2/2] extract early boot entropy from
 the passed cmdline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Kralevich <nnk@google.com>
Cc: Laura Abbott <labbott@redhat.com>, Daniel Micay <danielmicay@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 16, 2017 at 9:56 PM, Nick Kralevich <nnk@google.com> wrote:
> On Wed, Aug 16, 2017 at 3:46 PM, Laura Abbott <labbott@redhat.com> wrote:
>> From: Daniel Micay <danielmicay@gmail.com>
>>
>> Existing Android bootloaders usually pass data useful as early entropy
>> on the kernel command-line. It may also be the case on other embedded
>> systems. Sample command-line from a Google Pixel running CopperheadOS:
>>
>
> Why is it better to put this into the kernel, rather than just rely on
> the existing userspace functionality which does exactly the same
> thing? This is what Android already does today:
> https://android-review.googlesource.com/198113

That's too late for setting up the kernel stack canary, among other
things. The kernel will also be generating some early secrets for slab
cache canaries, etc. That all needs to happen well before init is
started.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
