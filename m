Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02E2E6B0069
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 21:08:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so680561pfj.21
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:08:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p66si2749399pga.805.2017.10.31.18.08.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 18:08:34 -0700 (PDT)
Subject: Re: [PATCH 01/23] x86, kaiser: prepare assembly for entry/exit CR3
 switching
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <20171031223148.5334003A@viggo.jf.intel.com>
 <CAMzpN2gP5SQWrbwNn9A+c6y5yLpqrV8Hpxou+TSypQ2WL+JXkQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <d85395ea-d848-6dd6-4e4d-d2ddba521bac@linux.intel.com>
Date: Tue, 31 Oct 2017 18:08:33 -0700
MIME-Version: 1.0
In-Reply-To: <CAMzpN2gP5SQWrbwNn9A+c6y5yLpqrV8Hpxou+TSypQ2WL+JXkQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, hughd@google.com, the arch/x86 maintainers <x86@kernel.org>

On 10/31/2017 05:43 PM, Brian Gerst wrote:
>>
>> +       RESTORE_CR3 save_reg=%r14
>> +
>>         testl   %ebx, %ebx                      /* swapgs needed? */
>>         jnz     nmi_restore
>>  nmi_swapgs:
>> _
> This all needs to be conditional on a config option.  Something with
> this amount of performance impact needs to be 100% optional.

The 07/23 patch does just this.  I should have at least called that out
in the description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
