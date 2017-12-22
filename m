Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7946B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:36:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u16so19851759pfh.7
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:36:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 65si14816823pgj.472.2017.12.22.00.36.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 00:36:22 -0800 (PST)
Date: Fri, 22 Dec 2017 09:36:15 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: general protection fault in finish_task_switch
Message-ID: <20171222083615.dr7jpzjjc6ye3eut@hirez.programming.kicks-ass.net>
References: <001a113ef748cc1ee50560c7b718@google.com>
 <CA+55aFyco00CBed1ADAz+EGtoP6w+nvuR2Y+YWH13cvkatOg4w@mail.gmail.com>
 <20171222081756.ur5uuh5wjri2ymyk@hirez.programming.kicks-ass.net>
 <CACT4Y+Z7__4qeMP-jG07-M+ugL3PxkQ_z83=TB8O9e4=jjV4ug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z7__4qeMP-jG07-M+ugL3PxkQ_z83=TB8O9e4=jjV4ug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, syzbot <bot+72c44cd8b0e8a1a64b9c03c4396aea93a16465ef@syzkaller.appspotmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jiang <dave.jiang@intel.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, tcharding <me@tobin.cc>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@infradead.org>, Eric Biggers <ebiggers3@gmail.com>

On Fri, Dec 22, 2017 at 09:26:28AM +0100, Dmitry Vyukov wrote:
> I think this is another manifestation of "KASAN: use-after-free Read
> in __schedule":
> https://groups.google.com/forum/#!msg/syzkaller-bugs/-8JZhr4W8AY/FpPFh8EqAQAJ
> +Eric already mailed a fix for it (indeed new bug in kvm code).

FWIW, these google links keep translating everything to my local
language, is there any way to tell google to not do stupid stuff like
that and give me English like computers ought to speak?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
