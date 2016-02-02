Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id F10FA6B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 16:24:06 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so42458532wmp.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:24:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y133si25303124wmb.56.2016.02.02.13.24.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Feb 2016 13:24:06 -0800 (PST)
Date: Tue, 2 Feb 2016 22:24:04 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: mm: uninterruptable tasks hanged on mmap_sem
In-Reply-To: <CACT4Y+Z=qaJjzOFsksSHur-kED=Jf-JFk_M0jnMNq1y5RG278A@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1602022222060.22727@cbobk.fhfr.pm>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com> <alpine.LNX.2.00.1602022204190.22727@cbobk.fhfr.pm> <CACT4Y+YHX-P0X8Y8530FoG2weg39edujD=1JyXZf6c67FM_xzw@mail.gmail.com>
 <CACT4Y+Z=qaJjzOFsksSHur-kED=Jf-JFk_M0jnMNq1y5RG278A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Tue, 2 Feb 2016, Dmitry Vyukov wrote:

> Original log from fuzzer contained the following WARNING in
> mm/rmap.c:412. But when I tried to reproduce it, I hit these hanged
> processes instead. I can't reliably detect what program triggered
> what. So it may be related, or maybe a separate issue.
> 
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:412!

Are you by any chance in this test sending signals to the fuzzer?

If so, the bug I just fixed in floppy driver can cause all kinds of memory 
corruptions in case you're running multithreaded accessess to /dev/fd0 and 
sending singals to the threads that are trying to access /dev/fd0 at the 
same time.

Could you please double check that the other floppy fix I've sent you a 
couple days ago doesn't fix this as well? (this test makes sense only if 
signals are involved though).

Thanks,

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
