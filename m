Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64B926B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:48:50 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n187so19951057pfn.10
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 01:48:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z27sor1577686pgc.29.2017.12.22.01.48.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Dec 2017 01:48:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171222093045.cblxhzev5drgtj4s@hirez.programming.kicks-ass.net>
References: <001a113ef748cc1ee50560c7b718@google.com> <CA+55aFyco00CBed1ADAz+EGtoP6w+nvuR2Y+YWH13cvkatOg4w@mail.gmail.com>
 <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
 <CACT4Y+Z7__4qeMP-jG07-M+ugL3PxkQ_z83=TB8O9e4=jjV4ug@mail.gmail.com>
 <20171222083615.dr7jpzjjc6ye3eut@hirez.programming.kicks-ass.net>
 <CACT4Y+Yb7a_tiGc4=NHSMpqv30-kBKO0iwAn79M6yv_EaRwG3w@mail.gmail.com>
 <20171222085730.c4kkiohz3fkwsqnr@hirez.programming.kicks-ass.net>
 <CACT4Y+YQZa+E5KbioAtadpUDLNSPtTJh7NAsmM-BvBUA1BUgmw@mail.gmail.com> <20171222093045.cblxhzev5drgtj4s@hirez.programming.kicks-ass.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 22 Dec 2017 10:48:28 +0100
Message-ID: <CACT4Y+a67mm-qwhuVb8OozRwvbpRbBScc6YZEj=nuNnzaG74XQ@mail.gmail.com>
Subject: Re: general protection fault in finish_task_switch
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, syzbot <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, tcharding <me@tobin.cc>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@infradead.org>, Eric Biggers <ebiggers3@gmail.com>

On Fri, Dec 22, 2017 at 10:30 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Fri, Dec 22, 2017 at 10:08:00AM +0100, Dmitry Vyukov wrote:
>
>> You mean the messages themselves are translated?
>
> No, just the webapp thing, which is bad enough. The actual messages are
> untouched.

Then try to open dev console in chromium (for me it's shift+ctrl+c),
reload the page, and then on the Network tab of dev console you can
see all request headers your browser sends. For me I see:

accept-language: en-US,en;q=0.9,ru;q=0.8

and the resulting page is in english.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
