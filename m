Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id C95F46B006E
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:15:29 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so1048043vcb.10
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:15:29 -0700 (PDT)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id m1si4784107vcm.90.2014.10.03.11.15.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Oct 2014 11:15:28 -0700 (PDT)
Received: by mail-vc0-f170.google.com with SMTP id hy10so1027986vcb.15
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:15:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1412356087-16115-2-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
	<1412356087-16115-2-git-send-email-aarcange@redhat.com>
Date: Fri, 3 Oct 2014 11:15:28 -0700
Message-ID: <CA+55aFwEO9=ieSb0uipfQ+qP9nP1ps=NCTe0HL9arK1cRYaJPg@mail.gmail.com>
Subject: Re: [PATCH 01/17] mm: gup: add FOLL_TRIED
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\Dr. David Alan Gilbert\\" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

This needs more explanation than that one-liner comment. Make the
commit message explain why the new FOLL_TRIED flag exists.

      Linus

On Fri, Oct 3, 2014 at 10:07 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> From: Andres Lagar-Cavilla <andreslc@google.com>
>
> Reviewed-by: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
