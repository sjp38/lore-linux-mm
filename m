Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD516B02F3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:06:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g13so12840458qta.6
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 12:06:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v68si3561131qkd.292.2017.08.29.12.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 12:06:49 -0700 (PDT)
Date: Tue, 29 Aug 2017 15:06:45 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH] mm/rmap: do not call mmu_notifier_invalidate_page()
 v3
Message-ID: <20170829190644.GC7546@redhat.com>
References: <20170829190526.8767-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170829190526.8767-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Aug 29, 2017 at 03:05:26PM -0400, Jerome Glisse wrote:
> Some MMU notifier need to be able to sleep during callback. This was
> broken by c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use
> page_vma_mapped_walk()").
> 
> This patch restore the sleep ability and properly capture the range of
> address that needs to be invalidated.
> 
> Relevent threads:
> https://lkml.kernel.org/r/20170809204333.27485-1-jglisse@redhat.com
> https://lkml.kernel.org/r/20170804134928.l4klfcnqatni7vsc@black.fi.intel.com
> https://marc.info/?l=kvm&m=150327081325160&w=2

Note that i haven't yet tested this patch i just wanted to put it
out there. I am gonna run some test over new few days an report.
Anyone else is welcome to test it too.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
