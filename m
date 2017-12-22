Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 649FD6B0253
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 05:37:59 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n62so5605721iod.17
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 02:37:59 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s82si6672820ioi.323.2017.12.22.02.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 02:37:58 -0800 (PST)
Date: Fri, 22 Dec 2017 11:37:40 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: general protection fault in finish_task_switch
Message-ID: <20171222103740.6w4d2daivf3ede5w@hirez.programming.kicks-ass.net>
References: <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
 <CACT4Y+Z7__4qeMP-jG07-M+ugL3PxkQ_z83=TB8O9e4=jjV4ug@mail.gmail.com>
 <20171222083615.dr7jpzjjc6ye3eut@hirez.programming.kicks-ass.net>
 <CACT4Y+Yb7a_tiGc4=NHSMpqv30-kBKO0iwAn79M6yv_EaRwG3w@mail.gmail.com>
 <20171222085730.c4kkiohz3fkwsqnr@hirez.programming.kicks-ass.net>
 <CACT4Y+YQZa+E5KbioAtadpUDLNSPtTJh7NAsmM-BvBUA1BUgmw@mail.gmail.com>
 <20171222093045.cblxhzev5drgtj4s@hirez.programming.kicks-ass.net>
 <CACT4Y+a67mm-qwhuVb8OozRwvbpRbBScc6YZEj=nuNnzaG74XQ@mail.gmail.com>
 <20171222100308.lllrvfhpvyhgc5yz@hirez.programming.kicks-ass.net>
 <CACT4Y+YDykOj9dTrWTs_mjqvT5Pd7ZX958KaiES0U9gLFnbL8A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YDykOj9dTrWTs_mjqvT5Pd7ZX958KaiES0U9gLFnbL8A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, syzbot <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, tcharding <me@tobin.cc>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@infradead.org>, Eric Biggers <ebiggers3@gmail.com>

On Fri, Dec 22, 2017 at 11:24:45AM +0100, Dmitry Vyukov wrote:

> I am in Germany. Also tried to open it unsigned from incognito window,
> still english...

Not sure what all happened, but I restarted Chrome and now your link at
least displays in English, hooray.

If I go to groups.google.com, still Dutch.

Weird stuff. But I can live with this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
