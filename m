Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDB26B025E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 13:42:32 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id l68so3767059wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 10:42:32 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id kt2si11466070wjb.42.2016.03.17.10.42.30
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 10:42:31 -0700 (PDT)
Date: Thu, 17 Mar 2016 17:42:26 +0000
From: Olu Ogunbowale <olu.ogunbowale@imgtec.com>
Subject: Re: [PATCH] mm: Export symbols unmapped_area() &
 unmapped_area_topdown()
Message-ID: <20160317174226.GC31608@imgtec.com>
References: <1458148234-4456-1-git-send-email-Olu.Ogunbowale@imgtec.com>
 <1458148234-4456-2-git-send-email-Olu.Ogunbowale@imgtec.com>
 <20160317143714.GA16297@gmail.com>
 <20160317154635.GA31608@imgtec.com>
 <20160317170348.GB16297@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
In-Reply-To: <20160317170348.GB16297@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S.
 Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter
 Anvin" <hpa@zytor.com>, Jackson DSouza <Jackson.DSouza@imgtec.com>

On Thu, Mar 17, 2016 at 06:03:50PM +0100, Jerome Glisse wrote:
> Well trick still works, if driver is loaded early during userspace program
> initialization then you force mmap to specific range inside the driver
> userspace code. If driver is loaded after and program is already using those
> range then you can register a notifier to track when those range. If they
> get release by the program you can have the userspace driver force creation
> of new reserve vma again.

I should have been more clearer in my response, this applies only because
we are in a scheme were all allocations must go through a special allocator 
because VMA base/range is reserved for SVM.

> Well controling range into which VMA can be allocated is not something that
> you should do lightly (thing like address space randomization would be
> impacted). And no the SVM range is not upper bound by the amount of memory
> but by the physical bus size if it is 48bits nothing forbid to put all the
> program memory above 8GB and nothing below. We are talking virtual address
> here. By the way i think most 64 bit ARM are 40 bits and it seems a shame
> for GPU to not go as high as the CPU.

Same as above. By the way, we support minimum 40-bits but can be paired with
CPU(s) of higher bits; no problem if bits are equal or greater than CPU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
