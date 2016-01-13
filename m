Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD03828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 18:43:39 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so273524690pab.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 15:43:39 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id m82si5045583pfi.249.2016.01.13.15.43.38
        for <linux-mm@kvack.org>;
        Wed, 13 Jan 2016 15:43:38 -0800 (PST)
Subject: Re: [RFC 09/13] x86/mm: Disable interrupts when flushing the TLB
 using CR3
References: <cover.1452294700.git.luto@kernel.org>
 <a75dbc8fb47148e7f7f3b171c033a5a11d83e690.1452294700.git.luto@kernel.org>
 <CA+55aFxChuKFYyUtG6a+zn82JFB=9XaM6mH9V+kdYa9iEDKUzQ@mail.gmail.com>
 <CALCETrX9yheo2VK=jhqvikumXrPfdHmNCLgkjugLQnLWSawv9A@mail.gmail.com>
 <CA+55aFy=mNDvedPwSF01F-QHEsFdGu63qiGPvmp_Cnhb0CvG+A@mail.gmail.com>
 <CALCETrVT7ePZPAySF45hhnhZ5cBKH0EvDGmxftHvUmZw2YxZjQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <5696E129.9000804@linux.intel.com>
Date: Wed, 13 Jan 2016 15:43:37 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrVT7ePZPAySF45hhnhZ5cBKH0EvDGmxftHvUmZw2YxZjQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Brian Gerst <brgerst@gmail.com>

On 01/13/2016 03:35 PM, Andy Lutomirski wrote:
> Can anyone here ask a hardware or microcode person what's going on
> with CR3 writes possibly being faster than INVPCID?  Is there some
> trick to it?

I just went and measured it myself this morning.  "INVPCID Type 3" (all
contexts no global) on a Skylake system was 15% slower than a CR3 write.

Is that in the same ballpark from what you've observed?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
