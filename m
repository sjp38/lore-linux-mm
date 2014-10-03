Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id A00446B006E
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:31:32 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id im17so1018598vcb.24
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:31:32 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id sn8si4803275vdc.88.2014.10.03.11.31.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Oct 2014 11:31:31 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id la4so1069527vcb.27
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:31:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1412356087-16115-11-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
	<1412356087-16115-11-git-send-email-aarcange@redhat.com>
Date: Fri, 3 Oct 2014 11:31:31 -0700
Message-ID: <CA+55aFx++R42L75ooE=Fmaem73=V=q7f6pYTcALxgrA1y98G-A@mail.gmail.com>
Subject: Re: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\Dr. David Alan Gilbert\\" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Fri, Oct 3, 2014 at 10:08 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>
> Overall this looks a fairly small change to the rmap code, notably
> less intrusive than the nonlinear vmas created by remap_file_pages.

Considering that remap_file_pages() was an unmitigated disaster, and
-mm has a patch to remove it entirely, I'm not at all convinced this
is a good argument.

We thought remap_file_pages() was a good idea, and it really really
really wasn't. Almost nobody used it, why would the anonymous page
case be any different?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
