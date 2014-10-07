Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 883CD6B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 07:10:53 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so7425140wiv.17
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 04:10:52 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.234])
        by mx.google.com with ESMTP id ba7si20464884wjc.158.2014.10.07.04.10.52
        for <linux-mm@kvack.org>;
        Tue, 07 Oct 2014 04:10:52 -0700 (PDT)
Date: Tue, 7 Oct 2014 14:10:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Qemu-devel] [PATCH 10/17] mm: rmap preparation for
 remap_anon_pages
Message-ID: <20141007111026.GD30762@node.dhcp.inet.fi>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-11-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412356087-16115-11-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Jan Kara <jack@suse.cz>, Neil Brown <neilb@suse.de>, Stefan Hajnoczi <stefanha@gmail.com>, Andrew Jones <drjones@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Taras Glek <tglek@mozilla.com>, Juan Quintela <quintela@redhat.com>, Hugh Dickins <hughd@google.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Mel Gorman <mgorman@suse.de>, Sasha Levin <sasha.levin@oracle.com>, Android Kernel Team <kernel-team@android.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Andres Lagar-Cavilla <andreslc@google.com>, Christopher Covington <cov@codeaurora.org>, Anthony Liguori <anthony@codemonkey.ws>, Paolo Bonzini <pbonzini@redhat.com>, Keith Packard <keithp@keithp.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mike Hommey <mh@glandium.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Feiner <pfeiner@google.com>

On Fri, Oct 03, 2014 at 07:08:00PM +0200, Andrea Arcangeli wrote:
> There's one constraint enforced to allow this simplification: the
> source pages passed to remap_anon_pages must be mapped only in one
> vma, but this is not a limitation when used to handle userland page
> faults with MADV_USERFAULT. The source addresses passed to
> remap_anon_pages should be set as VM_DONTCOPY with MADV_DONTFORK to
> avoid any risk of the mapcount of the pages increasing, if fork runs
> in parallel in another thread, before or while remap_anon_pages runs.

Have you considered triggering COW instead of adding limitation on
pages' mapcount? The limitation looks artificial from interface POV.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
