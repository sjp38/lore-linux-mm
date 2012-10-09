Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id BC3186B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 08:13:10 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so3667278wey.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 05:13:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1349776921.21172.4091.camel@edumazet-glaptop>
References: <20120731103724.20515.60334.stgit@zurg> <20120731104239.20515.702.stgit@zurg>
 <1349776921.21172.4091.camel@edumazet-glaptop>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 9 Oct 2012 21:12:48 +0900
Message-ID: <CA+55aFzCCSE3bnPL7pquYq9pW6YLs_2QZR7r9kZEgwxxc7rzYg@mail.gmail.com>
Subject: Re: [PATCH v3 10/10] mm: kill vma flag VM_RESERVED and
 mm->reserved_vm counter
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Alex Williamson <alex.williamson@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@kernel.dk>

On Tue, Oct 9, 2012 at 7:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> It seems drivers/vfio/pci/vfio_pci.c uses VM_RESERVED

Yeah, I just pushed out what I think is the right (trivial) fix.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
