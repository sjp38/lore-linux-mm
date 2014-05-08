Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id C8AB06B00F9
	for <linux-mm@kvack.org>; Thu,  8 May 2014 11:45:27 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id hw13so2684667qab.4
        for <linux-mm@kvack.org>; Thu, 08 May 2014 08:45:27 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id g67si683453qgf.64.2014.05.08.08.45.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 08:45:27 -0700 (PDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so2955389qgz.2
        for <linux-mm@kvack.org>; Thu, 08 May 2014 08:45:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Armin Rigo <arigo@tunes.org>
Date: Thu, 8 May 2014 17:44:46 +0200
Message-ID: <CAMSv6X0+3-uNeiyEPD3sA5dA6Af_M+BT0aeVpa3qMv1aga0q9g@mail.gmail.com>
Subject: Re: [PATCHv2 0/2] remap_file_pages() decommission
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org

Hi everybody,

Here is a note from the PyPy project (mentioned earlier in this
thread, and at https://lwn.net/Articles/587923/ ).

Yes, we use remap_file_pages() heavily on the x86-64 architecture.
However, the individual calls to remap_file_pages() are not
performance-critical, so it is easy to switch to using multiple
mmap()s.  We need to perform more measurements to know exactly what
the overhead would be, in terms notably of kernel memory.

However, an issue with that approach is the upper bound on the number
of VMAs.  By default, it is not large enough.  Right now, it is
possible to remap say 10% of the individual pages from an anonymous
mmap of multiple GBs in size; but doing so with individual calls to
mmap hits this arbitrary limit.  I have no particular weight to give
for or against keeping remap_file_pages() in the kernel, but if it is
removed or emulated, it would be a plus if the programs would run on a
machine with the default configuration --- i.e. if you remove or
emulate remap_file_pages(), please increase the default limit as well.


A bient=C3=B4t,

Armin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
