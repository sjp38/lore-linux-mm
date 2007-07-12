Subject: Re: lguest, Re: -mm merge plans for 2.6.23
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20070711.195126.02300228.davem@davemloft.net>
References: <1184203311.6005.664.camel@localhost.localdomain>
	 <20070711.192829.08323972.davem@davemloft.net>
	 <1184208521.6005.695.camel@localhost.localdomain>
	 <20070711.195126.02300228.davem@davemloft.net>
Content-Type: text/plain
Date: Thu, 12 Jul 2007 13:15:18 +1000
Message-Id: <1184210118.6005.719.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: hch@lst.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-11 at 19:51 -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Thu, 12 Jul 2007 12:48:41 +1000
> 
> > We drop the lock after I/O, and then do this wakeup.  Meanwhile the
> > other task might have exited.
> 
> I already understand what you're doing.
> 
> Is it possible to use exit notifiers to handle this case?
> That's what I'm trying to suggest. :)

Sure, the process has /dev/lguest open, so I can do something in the
close routine.  Instead of keeping a reference to the tsk, I can keep a
reference to the struct lguest (currently it doesn't have or need a
refcnt).  Then I need another lock, to protect lg->tsk.

This seems like a lot of dancing to avoid one export.  If it's that
important I'd far rather drop the code and do a normal wakeup under the
big lguest lock for 2.6.23.

Cheers,
Rusty.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
