Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 00DD96B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 12:53:17 -0400 (EDT)
Received: by mail-qe0-f54.google.com with SMTP id s14so2205761qeb.27
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 09:53:17 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Thu, 25 Apr 2013 18:53:16 +0200
Message-ID: <CA+icZUXdM1YpsYD3E1kh_RyWeZDPeHPYZmPe91ea3EDs0fGmLQ@mail.gmail.com>
Subject: Re: [v3,-mm,-next] ipc,sem: fix lockdep false positive
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, davidlohr.bueso@hp.com

Hi Andrew,

AFAICS all missing ipc-sem-next are in your mmots-tree except this one.
I am not following linux-mm that much, but what happened to it?

Thanks in advance.

Regards,
- Sedat -

P.S.:

$ diff -uprN series.mmotm series.mmots | grep -i ^+ipcsem | cut -d '+' -f2
ipcsem-fine-grained-locking-for-semtimedop-fix-locking-in-semctl_main.patch
ipcsem-fine-grained-locking-for-semtimedop-untangle-rcu-locking-with-find_alloc_undo.patch
ipcsem-fine-grained-locking-for-semtimedop-do-not-call-sem_lock-when-bogus-sma.patch
ipcsem-fine-grained-locking-for-semtimedop-ipc-make-refcounter-atomic.patch
ipcsem-fine-grained-locking-for-semtimedop-ipc-make-refcounter-atomic-fix.patch

[1] https://patchwork.kernel.org/patch/2365401/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
