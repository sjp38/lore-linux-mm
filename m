Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3446B02F3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:09:47 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 81so32152640ioj.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:09:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m184sor1175910ith.62.2017.08.29.12.09.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 12:09:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170829190526.8767-1-jglisse@redhat.com>
References: <20170829190526.8767-1-jglisse@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 Aug 2017 12:09:45 -0700
Message-ID: <CA+55aFy=+ipEWKYwckee7-QodyfwufejNq1WA3rSNUHKJiw+6g@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/rmap: do not call mmu_notifier_invalidate_page() v3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 29, 2017 at 12:05 PM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.c=
om> wrote:
> Some MMU notifier need to be able to sleep during callback. This was
> broken by c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use
> page_vma_mapped_walk()").

No. No no no.

Didn't you learn *anything* from the bug?

You cannot replace "mmu_notifier_invalidate_page()" with
"mmu_notifier_invalidate_range()".

KVM implements mmu_notifier_invalidate_page().

IT DOES NOT IMPLEMENT THAT RANGE CRAP AT ALL.

So any approach like this is fundamentally garbage. Really. Stop
sending crap. This is exactly tehe same thing that we already reverted
because it was broken shit. Why do you re-send it without actually
fixing the fundamental problems that were pointed out?

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
