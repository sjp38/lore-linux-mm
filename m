Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id AA09F6B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 18:37:35 -0400 (EDT)
Date: Thu, 23 Aug 2012 00:37:33 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 19/36] autonuma: memory follows CPU algorithm and task/mm_autonuma stats collection
Message-ID: <20120822223733.GQ16230@one.firstfloor.org>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com> <1345647560-30387-20-git-send-email-aarcange@redhat.com> <m2sjbe7k93.fsf@firstfloor.org> <20120822212459.GC8107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120822212459.GC8107@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> 
> This comment seems quite accurate to me (btw I taken it from
> sched-numa rewrite with minor changes).

I had expected it to describe the next function. If it's a strategic
overview maybe it should be somewhere else.

> Disabling irqs around lru_lock was an optimization to avoid increasing
> the hold time of the lock when all critical sections were short after
> the isolation code. Now it's used to rotate lrus at I/O completion too.

Thanks.
-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
