Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5A066B0387
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 16:10:28 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 45so42225142otd.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:10:28 -0800 (PST)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id 6si5293905otu.23.2017.02.17.13.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 13:10:28 -0800 (PST)
Received: by mail-oi0-x242.google.com with SMTP id w144so2483631oiw.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 13:10:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ae493a75-138c-9c01-d4a1-90bcd01d560f@intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com> <ae493a75-138c-9c01-d4a1-90bcd01d560f@intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Feb 2017 13:10:27 -0800
Message-ID: <CA+55aFzVWHUNuhTSBKLyLjOd4UQ8s1-RhMWA7oVr=3G5euo7ZQ@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux API <linux-api@vger.kernel.org>

On Fri, Feb 17, 2017 at 1:04 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>
> Is this likely to break anything in practice?  Nah.  But it would nice
> to avoid it.

So I go the other way: what *I* would like to avoid is odd code that
is hard to follow. I'd much rather make the code be simple and the
rules be straightforward, and not introduce that complicated
"different address limits" thing at all.

Then, _if_ we ever find a case where it makes a difference, we could
go the more complex route. But not first implementation, and not
without a real example of why we shouldn't just keep things simple.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
