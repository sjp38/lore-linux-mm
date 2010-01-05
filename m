Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 61F016007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:16:17 -0500 (EST)
Date: Tue, 5 Jan 2010 16:16:11 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] nommu: reject MAP_HUGETLB
In-Reply-To: <17220.1262705013@redhat.com>
Message-ID: <alpine.LSU.2.00.1001051536420.13371@sister.anvils>
References: <alpine.LSU.2.00.1001051232530.1055@sister.anvils> <alpine.LSU.2.00.0912302009040.30390@sister.anvils> <20100104123858.GA5045@us.ibm.com> <17220.1262705013@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Eric B Munson <ebmunson@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Jan 2010, David Howells wrote:
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> 
> > We've agreed to restore the rejection of MAP_HUGETLB to nommu.
> > Mimic what happens with mmu when hugetlb is not configured in:
> > say -ENOSYS, but -EINVAL if MAP_ANONYMOUS was not given too.
> 
> On the other hand, why not just ignore the MAP_HUGETLB flag on NOMMU?

I don't care very much either way: originally it was ignored,
then it became an -ENOSYS when Al moved the MAP_HUGETLB handling
into util.c, then it was ignored again when I moved that back into
mmap.c and nommu.c, now this patch makes it -ENOSYS on nommu again
- which Eric preferred.

I'd say this patch is _correct_; but I'm perfectly happy to have
you NAK it, or Linus ignore it, with the observation that nommu is
more likely to want to cut bloat than to be pedantically correct -
pedantic because I'd expect the nommu mmap() to work fine with the
MAP_HUGETLB flag there, just wouldn't be using any huge pages.

Okay with me whichever way it goes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
