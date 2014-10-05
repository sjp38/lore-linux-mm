Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id C90A76B0069
	for <linux-mm@kvack.org>; Sun,  5 Oct 2014 14:51:14 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id hq12so2435566vcb.9
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 11:51:14 -0700 (PDT)
Received: from mail-vc0-x22d.google.com (mail-vc0-x22d.google.com [2607:f8b0:400c:c03::22d])
        by mx.google.com with ESMTPS id st18si7062798vcb.20.2014.10.05.11.51.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 05 Oct 2014 11:51:13 -0700 (PDT)
Received: by mail-vc0-f173.google.com with SMTP id ij19so2362432vcb.32
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 11:51:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141005184115.GA21713@node.dhcp.inet.fi>
References: <alpine.DEB.2.02.1410041947080.7055@chino.kir.corp.google.com>
	<20141005184115.GA21713@node.dhcp.inet.fi>
Date: Sun, 5 Oct 2014 11:51:13 -0700
Message-ID: <CA+55aFzZMuup+00b7yLy=oLbzErEuUXxuBuwGcDCbjM5PbYKaQ@mail.gmail.com>
Subject: Re: [patch for-3.17] mm, thp: fix collapsing of hugepages on madvise
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Suleiman Souhlal <suleiman@google.com>, stable <stable@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, Oct 5, 2014 at 11:41 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Look like rather complex fix for a not that complex bug.
> What about untested patch below?

Much nicer. This will miss 3.17 because I'm cutting it today and it's
too late to have this discussion for that, but I think I'd prefer to
merge this instead later..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
