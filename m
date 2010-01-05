Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 623BC6007E1
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 10:23:42 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <alpine.LSU.2.00.1001051232530.1055@sister.anvils>
References: <alpine.LSU.2.00.1001051232530.1055@sister.anvils> <alpine.LSU.2.00.0912302009040.30390@sister.anvils> <20100104123858.GA5045@us.ibm.com>
Subject: Re: [PATCH] nommu: reject MAP_HUGETLB
Date: Tue, 05 Jan 2010 15:23:33 +0000
Message-ID: <17220.1262705013@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: dhowells@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>, Eric B Munson <ebmunson@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> We've agreed to restore the rejection of MAP_HUGETLB to nommu.
> Mimic what happens with mmu when hugetlb is not configured in:
> say -ENOSYS, but -EINVAL if MAP_ANONYMOUS was not given too.

On the other hand, why not just ignore the MAP_HUGETLB flag on NOMMU?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
