Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A067F6B02FA
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 16:10:58 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n74so4662880ioe.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 13:10:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c88sor296133ioj.103.2017.08.31.12.40.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Aug 2017 12:40:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170831182555.GF9227@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com> <20170829235447.10050-3-jglisse@redhat.com>
 <20170830165250.GD13559@redhat.com> <CA+55aFxiyrqasfojwS5rG4aKJfaZpw1H=QAPH+9PRq=HT0W8AQ@mail.gmail.com>
 <20170830230125.GL13559@redhat.com> <20170831182555.GF9227@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 Aug 2017 12:40:02 -0700
Message-ID: <CA+55aFwbddL752cZskF7RxvOHtKov46krG29OzEu-J_GVp_e7Q@mail.gmail.com>
Subject: Re: [PATCH 02/13] mm/rmap: update to new mmu_notifier semantic
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 31, 2017 at 11:25 AM, Jerome Glisse <jglisse@redhat.com> wrote:
>
> This optimization is safe i believe. Linus i can respin with that and
> with further kvm dead code removal.

Yes, please.

And if you've been tracking the reviewed-by and tested-by's that would
be really good too. I lost much of yesterday to a sudden kidney stone
emergency, so I might not have tracked every ack.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
