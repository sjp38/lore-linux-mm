Date: Tue, 29 Apr 2008 03:56:07 -0700 (PDT)
Message-Id: <20080429.035607.224699531.davem@davemloft.net>
Subject: Re: [rfc] data race in page table setup/walking?
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080429050054.GC21795@wotan.suse.de>
References: <20080429050054.GC21795@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Tue, 29 Apr 2008 07:00:54 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: torvalds@linux-foundation.org, hugh@veritas.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

> So anyway... comments, please? Am I dreaming the whole thing up? I suspect
> that if I'm not, then powerpc at least might have been impacted by the race,
> but as far as I know of, they haven't seen stability problems around there...
> Might just be terribly rare, though. I'd like to try to make a test program
> to reproduce the problem if I can get access to a box...

This definitely does look like a real problem, albeit pretty hard to
trigger I would say. :-)

Thanks for looking into this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
