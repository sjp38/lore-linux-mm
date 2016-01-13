Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5C2828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 18:51:56 -0500 (EST)
Received: by mail-oi0-f42.google.com with SMTP id k206so105147571oia.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:51:56 -0800 (PST)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id dp7si4187926obb.40.2016.01.13.15.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 15:51:55 -0800 (PST)
Received: by mail-ob0-x232.google.com with SMTP id vt7so69361904obb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:51:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5696E129.9000804@linux.intel.com>
References: <cover.1452294700.git.luto@kernel.org> <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
 <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
 <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
 <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
 <CALCETrVT7ePZPAySF45hhnhZ5cBKH0EvDGmxftHvUmZw2YxZjQ@mail.gmail.com> <5696E129.9000804@linux.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 13 Jan 2016 15:51:35 -0800
Message-ID: <CALCETrVTO9NoxW-6zEAhHCa2ttQTKA0B+_0OCY-Qe10SwuTFag@mail.gmail.com>
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>

On Wed, Jan 13, 2016 at 3:43 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 01/13/2016 03:35 PM, Andy Lutomirski wrote:
>> Can anyone here ask a hardware or microcode person what's going on
>> with CR3 writes possibly being faster than INVPCID?  Is there some
>> trick to it?
>
> I just went and measured it myself this morning.  "INVPCID Type 3" (all
> contexts no global) on a Skylake system was 15% slower than a CR3 write.
>
> Is that in the same ballpark from what you've observed?
>
>

It's similar, except that I was comparing "INVPCID Type 1" (single
context no globals) to a CR3 write.

Type 2, at least, is dramatically faster than the pair of CR4 writes
it replaces.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
