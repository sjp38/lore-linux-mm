Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id B8A416B006E
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 15:37:23 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id w8so5419328qac.40
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 12:37:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m9si9548094qge.171.2014.04.22.12.37.22
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 12:37:23 -0700 (PDT)
Date: Tue, 22 Apr 2014 15:09:28 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.15rc2 hanging processes on exit.
Message-ID: <20140422190928.GA25183@redhat.com>
References: <20140422180308.GA19038@redhat.com>
 <CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

On Tue, Apr 22, 2014 at 11:57:50AM -0700, Linus Torvalds wrote:
 
 > Are you testing anything new? Or is this strictly new to 3.15? The
 > only thing in this area we do differently is commit cda540ace6a1 ("mm:
 > get_user_pages(write,force) refuse to COW in shared areas"), but
 > fault_in_user_writeable() never used the force bit afaik. Adding Hugh
 > just in case.

You mean new as in additions to trinity ?
The only recent chance that might be relevant is that now, when I create
struct iovec's to pass to syscalls, I populate them solely with results
from mmap's rather than a mix of mmaps and mallocs.  The mmaps could be
all kinds of sizes, types etc. [*]  So now there's more chance I guess
that an iovec contains a bunch of hugepages, or read-only pages etc.

I took another slightly longer trace of what's going on at
http://codemonkey.org.uk/junk/trace2.out
But it looks to me to be pretty similar.

	Dave

[*] https://github.com/kernelslacker/trinity/commit/1e73841971717256089d63e9f7fc33972d48028c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
