Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 72DCF6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:30:58 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id a3so10174430itg.7
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 01:30:58 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a85si6643237itb.127.2017.12.22.01.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 01:30:57 -0800 (PST)
Date: Fri, 22 Dec 2017 10:30:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: general protection fault in finish_task_switch
Message-ID: <20171222093045.cblxhzev5drgtj4s@hirez.programming.kicks-ass.net>
References: <001a113ef748cc1ee50560c7b718@google.com>
 <CA+55aFyco00CBed1ADAz+EGtoP6w+nvuR2Y+YWH13cvkatOg4w@mail.gmail.com>
 <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
 <CACT4Y+Z7__4qeMP-jG07-M+ugL3PxkQ_z83=TB8O9e4=jjV4ug@mail.gmail.com>
 <20171222083615.dr7jpzjjc6ye3eut@hirez.programming.kicks-ass.net>
 <CACT4Y+Yb7a_tiGc4=NHSMpqv30-kBKO0iwAn79M6yv_EaRwG3w@mail.gmail.com>
 <20171222085730.c4kkiohz3fkwsqnr@hirez.programming.kicks-ass.net>
 <CACT4Y+YQZa+E5KbioAtadpUDLNSPtTJh7NAsmM-BvBUA1BUgmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YQZa+E5KbioAtadpUDLNSPtTJh7NAsmM-BvBUA1BUgmw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, syzbot <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, tcharding <me@tobin.cc>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@infradead.org>, Eric Biggers <ebiggers3@gmail.com>

On Fri, Dec 22, 2017 at 10:08:00AM +0100, Dmitry Vyukov wrote:

> You mean the messages themselves are translated?

No, just the webapp thing, which is bad enough. The actual messages are
untouched.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
