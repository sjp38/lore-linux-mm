Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id C186E6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:04:12 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so136647312ykd.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:04:12 -0700 (PDT)
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com. [209.85.160.174])
        by mx.google.com with ESMTPS id g187si7971770ywe.293.2015.10.12.08.04.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 08:04:12 -0700 (PDT)
Received: by ykey125 with SMTP id y125so14778083yke.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:04:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
Date: Mon, 12 Oct 2015 11:04:11 -0400
Message-ID: <CACh33FoFK4tbKFgcvN3mBuW7V=pMjM=X7eO68Pp9+56pH4B-EQ@mail.gmail.com>
Subject: Re: [PATCH 0/7] userfault21 update
From: Patrick Donnelly <batrick@batbytes.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hello Andrea,

On Mon, Jun 15, 2015 at 1:22 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> This is an incremental update to the userfaultfd code in -mm.

Sorry I'm late to this party. I'm curious how a ptrace monitor might
use a userfaultfd to handle faults in all of its tracees. Is this
possible without having each (newly forked) tracee "cooperate" by
creating a userfaultfd and passing that to the tracer?

Have you considered using one userfaultfd for an entire tree of
processes (signaled through a flag)? Would not a process id included
in the include/uapi/linux/userfaultfd.h:struct uffd_msg be sufficient
to disambiguate faults?

-- 
Patrick Donnelly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
