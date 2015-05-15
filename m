Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1356B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 14:22:10 -0400 (EDT)
Received: by iepk2 with SMTP id k2so123123781iep.3
        for <linux-mm@kvack.org>; Fri, 15 May 2015 11:22:10 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id o20si2800070icm.2.2015.05.15.11.22.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 11:22:09 -0700 (PDT)
Received: by ieczm2 with SMTP id zm2so51194881iec.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 11:22:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150515160426.GD19097@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
	<1431624680-20153-11-git-send-email-aarcange@redhat.com>
	<CA+55aFwCODeiXUPDR7-Y-=2xE2abmVuCnmVV=ezFqhO+JkaW=A@mail.gmail.com>
	<20150515160426.GD19097@redhat.com>
Date: Fri, 15 May 2015 11:22:09 -0700
Message-ID: <CA+55aFyPY9PtGLaK=TxBX_bU44MBCe53yLXDFzU43zJqbwzQ6Q@mail.gmail.com>
Subject: Re: [PATCH 10/23] userfaultfd: add new syscall to provide memory externalization
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Fri, May 15, 2015 at 9:04 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> To fix it I added this along a comment:

Ok, this looks good as a explanation/fix for the races (and also as an
example of my worry about waitqueue_active() use in general).

However, it now makes me suspect that the optimistic "let's check if
they are even active" may not be worth it any more. You're adding a
"smp_mb()" in order to avoid taking the real lock. Although I guess
there are two locks there (one for each wait-queue) so maybe it's
worth it.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
