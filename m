Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B775F6B02F3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:14:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q38so12991521qte.4
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:14:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si3396015qkd.109.2017.08.29.12.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 12:14:55 -0700 (PDT)
Date: Tue, 29 Aug 2017 15:14:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH] mm/rmap: do not call mmu_notifier_invalidate_page()
 v3
Message-ID: <20170829191449.GE7546@redhat.com>
References: <20170829190526.8767-1-jglisse@redhat.com>
 <CA+55aFy=+ipEWKYwckee7-QodyfwufejNq1WA3rSNUHKJiw+6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFy=+ipEWKYwckee7-QodyfwufejNq1WA3rSNUHKJiw+6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 29, 2017 at 12:09:45PM -0700, Linus Torvalds wrote:
> On Tue, Aug 29, 2017 at 12:05 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> > Some MMU notifier need to be able to sleep during callback. This was
> > broken by c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use
> > page_vma_mapped_walk()").
> 
> No. No no no.
> 
> Didn't you learn *anything* from the bug?
> 
> You cannot replace "mmu_notifier_invalidate_page()" with
> "mmu_notifier_invalidate_range()".
> 
> KVM implements mmu_notifier_invalidate_page().
> 
> IT DOES NOT IMPLEMENT THAT RANGE CRAP AT ALL.
> 
> So any approach like this is fundamentally garbage. Really. Stop
> sending crap. This is exactly tehe same thing that we already reverted
> because it was broken shit. Why do you re-send it without actually
> fixing the fundamental problems that were pointed out?
> 

Sorry i missed the kvm not implementing the range() only callback so
i am gonna respin with start/end.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
