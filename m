Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id E57E86B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 14:32:25 -0500 (EST)
Received: by igal13 with SMTP id l13so44590923iga.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 11:32:25 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id w1si2677466ica.67.2015.03.05.11.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 11:32:25 -0800 (PST)
Received: by igal13 with SMTP id l13so44590824iga.1
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 11:32:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150305185112.GL4280@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
	<1425575884-2574-20-git-send-email-aarcange@redhat.com>
	<CA+55aFzW=qaO0iKZWK9BWDNHu4eOgiKOJ-=0SvzsmZawuH5_3A@mail.gmail.com>
	<20150305185112.GL4280@redhat.com>
Date: Thu, 5 Mar 2015 11:32:24 -0800
Message-ID: <CA+55aFzK7kyZH0eiBH2CNDJ+p0oQYDZpm8tZitTgedOJz_He5Q@mail.gmail.com>
Subject: Re: [PATCH 19/21] userfaultfd: remap_pages: UFFDIO_REMAP preparation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Android Kernel Team <kernel-team@android.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Thu, Mar 5, 2015 at 10:51 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> Thanks for your idea that the UFFDIO_COPY is faster, the userland code
> we submitted for qemu only uses UFFDIO_COPY|ZEROPAGE, it never uses
> UFFDIO_REMAP.

Ok. So there's no actual expected use of the remap interface. Good.
That makes this series more palatable, since the rest didn't raise my
hackles much.

(But yeah, the documentation patch didn't really explain the uses very
much or at all, so I think something more is needed in that area).

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
