Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3EA6B0253
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 03:07:49 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s75so5018342pgs.12
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:07:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o11si1385710pll.537.2017.11.02.00.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 00:07:48 -0700 (PDT)
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 171732193B
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:07:48 +0000 (UTC)
Received: by mail-io0-f181.google.com with SMTP id p186so11586069ioe.12
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 00:07:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711012225400.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 2 Nov 2017 00:07:26 -0700
Message-ID: <CALCETrVa1rO9Jn0gh40Y_V_f_dE-1oPk25To29RD8Nb9GeMC2Q@mail.gmail.com>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, Nov 1, 2017 at 2:28 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Wed, 1 Nov 2017, Andy Lutomirski wrote:
>
>> On Wed, Nov 1, 2017 at 2:11 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
>> > On Tue, 31 Oct 2017, Dave Hansen wrote:
>> >
>> >>
>> >> init_mm is for kernel-exclusive use.  If someone is allocating page
>> >> tables in it, do not set _PAGE_USER on them.  This ensures that
>> >> we do *not* set NX on these page tables in the KAISER code.
>> >
>> > This changelog is confusing at best.
>> >
>> > Why is this a kaiser issue? Nothing should ever create _PAGE_USER entries
>> > in init_mm, right?
>>
>> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.
>
> Groan, forgot about that abomination, but still there is no point in having
> it marked PAGE_USER in the init_mm at all, kaiser or not.
>

How can it be PAGE_USER in user mms but not init_mm?  It's the same page table.

> Thanks,
>
>         tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
