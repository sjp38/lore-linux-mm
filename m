Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2774B6B025C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 12:55:09 -0500 (EST)
Received: by qgec40 with SMTP id c40so94094208qge.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 09:55:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t130si13379347qhb.55.2015.12.04.09.55.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 09:55:08 -0800 (PST)
Date: Fri, 4 Dec 2015 18:55:03 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01/23] userfaultfd: linux/Documentation/vm/userfaultfd.txt
Message-ID: <20151204175503.GZ29105@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-2-git-send-email-aarcange@redhat.com>
 <55F29513.4030503@gmail.com>
 <5661B62B.2020409@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5661B62B.2020409@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hello Michael,

On Fri, Dec 04, 2015 at 04:50:03PM +0100, Michael Kerrisk (man-pages) wrote:
> Hi Andrea,
> 
> On 09/11/2015 10:47 AM, Michael Kerrisk (man-pages) wrote:
> > On 05/14/2015 07:30 PM, Andrea Arcangeli wrote:
> >> Add documentation.
> > 
> > Hi Andrea,
> > 
> > I do not recall... Did you write a man page also for this new system call?
> 
> No response to my last mail, so I'll try again... Did you 
> write any man page for this interface?

I wished I would answer with the manpage itself to give a more
satisfactory answer, but answer is still no at this time. Right now
there's the write protection tracking feature posted to linux-mm and
I'm currently reviewing that. It's worth documenting that part too in
the manpage as it's going to happen sooner than later.

Lack of manpage so far didn't prevent userland to use it (qemu
postcopy is already in upstream qemu and it depends on userfaultfd),
nor review of the code nor other kernel contributors to extend the
syscall API. Other users started testing the syscall too. This is just
to explain why unfortunately the manpage didn't get the top priority
yet, but nevertheless the manpage should happen too and it's
important. Advice on how to proceed is welcome.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
