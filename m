Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86F3D280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:16:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q53so13421518qtq.3
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 13:16:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n65si3605407qkc.210.2017.08.29.13.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 13:16:00 -0700 (PDT)
Date: Tue, 29 Aug 2017 16:15:56 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/4] mmu_notifier semantic update
Message-ID: <20170829201555.GG7546@redhat.com>
References: <20170829201132.9292-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170829201132.9292-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Aug 29, 2017 at 04:11:28PM -0400, Jerome Glisse wrote:
> So we do not want to allow sleep during call to mmu_notifier_invalidate_page()
> but some code do not have surrounding mmu_notifier_invalidate_range_start()/
> mmu_notifier_invalidate_range_end() or mmu_notifier_invalidate_range()
> 
> This patch serie just make sure that there is at least a call (outside spinlock
> section) to mmu_notifier_invalidate_range() after mmu_notifier_invalidate_page()
> 
> This fix issue with AMD IOMMU v2 while avoiding to introduce issue for others
> user of the mmu_notifier API. For releavent threads see:
> 
> https://lkml.kernel.org/r/20170809204333.27485-1-jglisse@redhat.com
> https://lkml.kernel.org/r/20170804134928.l4klfcnqatni7vsc@black.fi.intel.com
> https://marc.info/?l=kvm&m=150327081325160&w=2

Please ignore this. Instead plan is to kill invalidate_page() switch
it to invalidate_range() and make sure there is always range_start/
range_end happening around.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
