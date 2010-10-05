Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F77E6B004A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 13:34:37 -0400 (EDT)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o95HY2ok017701
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 10:34:02 -0700
Received: by iwn41 with SMTP id 41so973508iwn.14
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 10:34:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1286265215-9025-3-git-send-email-walken@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com> <1286265215-9025-3-git-send-email-walken@google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Oct 2010 10:33:37 -0700
Message-ID: <AANLkTimyZc1ggSgvBS_=t3e1yr7EFBMK-uHvFcuVB8jC@mail.gmail.com>
Subject: Re: [PATCH 2/3] Retry page fault when blocking on disk transfer.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 5, 2010 at 12:53 AM, Michel Lespinasse <walken@google.com> wrote:
>
> This change reduces mmap_sem hold times that are caused by waiting for
> disk transfers when accessing file mapped VMAs.

Ok, this series looks much better. The new mm/filemap.c diff looks
much better with the lock_page_or_retry() helper function, and on the
whole I think I can Ack this (although obviously not actually apply it
- but please do get it into linux-next).

The do_page_fault() part of the patch still looks ugly, but I don't
see any obvious way to improve on it.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
