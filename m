Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 41EDF6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 16:08:17 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id x10so86279pdj.39
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 13:08:16 -0700 (PDT)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id oz6si5492127pac.420.2014.04.25.13.08.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 13:08:16 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so3562161pbb.25
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 13:08:15 -0700 (PDT)
Date: Fri, 25 Apr 2014 13:07:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: get_user_pages(write,force) refuse to COW in shared
 areas
In-Reply-To: <20140425190931.GA11323@redhat.com>
Message-ID: <alpine.LSU.2.11.1404251254230.6272@eggly.anvils>
References: <alpine.LSU.2.11.1404040120110.6880@eggly.anvils> <20140424133055.GA13269@redhat.com> <alpine.LSU.2.11.1404241518510.4454@eggly.anvils> <20140425190931.GA11323@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Roland Dreier <roland@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mauro Carvalho Chehab <m.chehab@samsung.com>, Omar Ramirez Luna <omar.ramirez@copitl.com>, Inki Dae <inki.dae@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org

On Fri, 25 Apr 2014, Oleg Nesterov wrote:
> 
> And I forgot to mention, there is another reason why I would like to
> change uprobes to follow the same convention. I still think it would
> be better to kill __replace_page() and use gup(FOLL_WRITE | FORCE)
> in uprobe_write_opcode().

Oh, please please do!  I assumed there was a good atomicity reason
for doing it that way, but if you can do it with gup() please do so.

I went off into a little rant about __replace_page() in my reply to you;
but then felt that you had approached with an honest enquiry, and didn't
deserve a rant in response, so I deleted it.

And, of course, I'm conscious that I have from start to finish withheld
my involvement from uprobes, and refused to review that __replace_page()
(beyond insisting that it not be put in a common place for sharing with
KSM, because I just couldn't guarantee it for uprobes).  I'm afraid that
it's much like HWPoison to me, a complexity (nastiness?) way beyond what
I have time to support myself.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
