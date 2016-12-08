Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78E946B0069
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 13:26:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so655799980pfb.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 10:26:59 -0800 (PST)
Received: from mail.zytor.com (torg.zytor.com. [2001:1868:205::12])
        by mx.google.com with ESMTPS id 34si29978638pln.78.2016.12.08.10.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 10:26:58 -0800 (PST)
In-Reply-To: <CA+55aFz+-8RmOMqyqQOWSjJ82byy7BpJ791-gj=xO2rPKG6KFA@mail.gmail.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com> <CA+55aFz+-8RmOMqyqQOWSjJ82byy7BpJ791-gj=xO2rPKG6KFA@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [RFC, PATCHv1 00/28] 5-level paging
From: hpa@zytor.com
Date: Thu, 08 Dec 2016 10:26:38 -0800
Message-ID: <6D8D56F4-6056-4533-BCFE-5FE292195D34@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On December 8, 2016 10:16:07 AM PST, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>On Thu, Dec 8, 2016 at 8:21 AM, Kirill A. Shutemov
><kirill.shutemov@linux.intel.com> wrote:
>>
>> This patchset is still very early. There are a number of things
>missing
>> that we have to do before asking anyone to merge it (listed below).
>> It would be great if folks can start testing applications now (in
>QEMU) to
>> look for breakage.
>> Any early comments on the design or the patches would be appreciated
>as
>> well.
>
>Looks ok to me. Starting off with a compile-time config option seems
>fine.
>
>I do think that the x86 cpuid part should (patch 15) should be the
>first patch, so that we see "la57" as a capability in /proc/cpuinfo
>whether it's being enabled or not? We should merge that part
>regardless of any mm patches, I think.
>
>               Linus

Definitely.
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
