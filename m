Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 594C16B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 06:37:42 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so8781747wgh.34
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 03:37:41 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.226])
        by mx.google.com with ESMTP id ws1si20476979wjb.85.2014.10.07.03.37.41
        for <linux-mm@kvack.org>;
        Tue, 07 Oct 2014 03:37:41 -0700 (PDT)
Date: Tue, 7 Oct 2014 13:36:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 08/17] mm: madvise MADV_USERFAULT
Message-ID: <20141007103645.GB30762@node.dhcp.inet.fi>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
 <1412356087-16115-9-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412356087-16115-9-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Fri, Oct 03, 2014 at 07:07:58PM +0200, Andrea Arcangeli wrote:
> MADV_USERFAULT is a new madvise flag that will set VM_USERFAULT in the
> vma flags. Whenever VM_USERFAULT is set in an anonymous vma, if
> userland touches a still unmapped virtual address, a sigbus signal is
> sent instead of allocating a new page. The sigbus signal handler will
> then resolve the page fault in userland by calling the
> remap_anon_pages syscall.

Hm. I wounder if this functionality really fits madvise(2) interface: as
far as I understand it, it provides a way to give a *hint* to kernel which
may or may not trigger an action from kernel side. I don't think an
application will behaive reasonably if kernel ignore the *advise* and will
not send SIGBUS, but allocate memory.

I would suggest to consider to use some other interface for the
functionality: a new syscall or, perhaps, mprotect().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
