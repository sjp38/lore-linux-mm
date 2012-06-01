Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B62A66B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 09:43:30 -0400 (EDT)
Date: Fri, 1 Jun 2012 09:43:23 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
Message-ID: <20120601134323.GA5214@redhat.com>
References: <20120530163317.GA13189@redhat.com>
 <20120531005739.GA4532@redhat.com>
 <20120601023107.GA19445@redhat.com>
 <CA+55aFyNSUbTfY4YdH4OcrrRnwkw-sHy3aT18ynf-YXRXSJQ8Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyNSUbTfY4YdH4OcrrRnwkw-sHy3aT18ynf-YXRXSJQ8Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Cong Wang <amwang@redhat.com>

On Thu, May 31, 2012 at 07:43:25PM -0700, Linus Torvalds wrote:
 > On Thu, May 31, 2012 at 7:31 PM, Dave Jones <davej@redhat.com> wrote:
 > >
 > > So I bisected it anyway, and it led to ...
 > 
 > Ok, that doesn't sound entirely unlikely, but considering that you're
 > nervous about the bisection, please just try to revert it and see if
 > that fixes your testcase.
 > 
 > You'll obviously need to revert the commit that removes
 > vmtruncate_range() too, since reverting 3f31d07571ee will re-introduce
 > the use of it (it's the next one:
 > 17cf28afea2a1112f240a3a2da8af883be024811), but it looks like those two
 > commits revert cleanly and the end result seems to compile ok.

crap, so much for that theory.  I ran latest with those two reverted
overnight, and woke up to a dead box.  Over serial console, I see
a bunch of those same compaction oopses (Via sys_mmap_pgoff),
and then kernel BUG at include/linux/mm.h:448! was the last thing
it said before it choked.

I'll redo the bisect. It's possible that one of the 'good' paths just
didn't run for long enough.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
