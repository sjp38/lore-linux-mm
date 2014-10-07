Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1020D6B0069
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 13:15:35 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id i17so6165852qcy.2
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 10:15:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y19si26938247qaw.92.2014.10.07.10.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Oct 2014 10:15:34 -0700 (PDT)
Message-ID: <54341F77.6060400@redhat.com>
Date: Tue, 07 Oct 2014 19:14:31 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com> <1412356087-16115-11-git-send-email-aarcange@redhat.com> <CA+55aFx++R42L75ooE=Fmaem73=V=q7f6pYTcALxgrA1y98G-A@mail.gmail.com> <20141006085540.GD2336@work-vm> <20141006164156.GA31075@redhat.com> <CA+55aFxAOYBny+QwXfkPy-P3rs-RPr5SLYLcPNBiFO3waBXtQA@mail.gmail.com> <20141007170731.GO2404@work-vm>
In-Reply-To: <20141007170731.GO2404@work-vm>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

Il 07/10/2014 19:07, Dr. David Alan Gilbert ha scritto:
>> > 
>> > So I'd *much* rather have a "write()" style interface (ie _copying_
>> > bytes from user space into a newly allocated page that gets mapped)
>> > than a "remap page" style interface
> Something like that might work for the postcopy case; it doesn't work
> for some of the other uses that need to stop a page being changed by the
> guest, but then need to somehow get a copy of that page internally to QEMU,
> and perhaps provide it back later.

I cannot parse this.  Which uses do you have in mind?  Is it for
QEMU-specific or is it for other applications of userfaults?

As long as the page is atomically mapped, I'm not sure what the
difference from remap_anon_pages are (as far as the destination page is
concerned).  Are you thinking of having userfaults enabled on the source
as well?

Paolo

> remap_anon_pages worked for those cases
> as well; I can't think of another current way of doing it in userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
