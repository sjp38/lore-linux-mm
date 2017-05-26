Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 478706B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 15:21:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 62so24258352pft.3
        for <linux-mm@kvack.org>; Fri, 26 May 2017 12:21:55 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id 21si1755264pgh.402.2017.05.26.12.21.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 12:21:54 -0700 (PDT)
Date: Fri, 26 May 2017 11:24:39 -0700
In-Reply-To: <CA+55aFw2HDHRZTYss2xbSTRAZuS1qAFmKrAXsiMp34ngNapTiw@mail.gmail.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com> <CA+55aFznnXPDxYy5CN6qVU7QJ3Y9hbSf-s2-w0QkaNJuTspGcQ@mail.gmail.com> <20170526130057.t7zsynihkdtsepkf@node.shutemov.name> <CA+55aFw2HDHRZTYss2xbSTRAZuS1qAFmKrAXsiMp34ngNapTiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv1, RFC 0/8] Boot-time switching between 4- and 5-level paging
From: hpa@zytor.com
Message-ID: <83F4880B-5D1F-4576-A9B6-7DDF4173E2E5@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On May 26, 2017 8:51:48 AM PDT, Linus Torvalds <torvalds@linux-foundation=
=2Eorg> wrote:
>On Fri, May 26, 2017 at 6:00 AM, Kirill A=2E Shutemov
><kirill@shutemov=2Ename> wrote:
>>
>> I don't see how kernel threads can use 4-level paging=2E It doesn't
>work
>> from virtual memory layout POV=2E Kernel claims half of full virtual
>address
>> space for itself -- 256 PGD entries, not one as we would effectively
>have
>> in case of switching to 4-level paging=2E For instance, addresses,
>where
>> vmalloc and vmemmap are mapped, are not canonical with 4-level
>paging=2E
>
>I would have just assumed we'd map the kernel in the shared part that
>fits in the top 47 bits=2E
>
>But it sounds like you can't switch back and forth anyway, so I guess
>it's moot=2E
>
>Where *is* the LA57 documentation, btw? I had an old x86 architecture
>manual, so I updated it, but LA57 isn't mentioned in the new one
>either=2E
>
>                       Linus

As one of the major motivations for LA57 is that we expect that we will ha=
ve machines with more than 2^46 bytes of memory in the near future, it isn'=
t feasible in most cases to do per-VM LA57=2E

The only case where that even has any utility is for an application to wan=
t more than 128 TiB address space on a machine with no more than 64 TiB of =
RAM=2E  It is kind of a narrow use case, I think=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
