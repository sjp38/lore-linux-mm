Date: Sat, 6 May 2000 12:48:09 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Helding the Kernel lock while doing IO???
Message-ID: <20000506124809.C4994@redhat.com>
References: <yttpur0wjlk.fsf@vexeta.dc.fi.udc.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <yttpur0wjlk.fsf@vexeta.dc.fi.udc.es>; from quintela@fi.udc.es on Sat, May 06, 2000 at 03:30:47AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, May 06, 2000 at 03:30:47AM +0200, Juan J. Quintela wrote:
> 
> read_swap_cache is called synchronously, then we can have to wait
> until we read the page to liberate the lock kernel.  It is intended?
> I am losing some detail?

Holding the big kernel lock while we sleep is quite legal.  The 
scheduler drops the lock while we sleep and reacquires it when we
are rescheduled.  The lock_kernel() lock is not at all like other
spinlocks.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
