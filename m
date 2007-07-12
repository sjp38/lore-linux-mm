Date: Wed, 11 Jul 2007 19:51:26 -0700 (PDT)
Message-Id: <20070711.195126.02300228.davem@davemloft.net>
Subject: Re: lguest, Re: -mm merge plans for 2.6.23
From: David Miller <davem@davemloft.net>
In-Reply-To: <1184208521.6005.695.camel@localhost.localdomain>
References: <1184203311.6005.664.camel@localhost.localdomain>
	<20070711.192829.08323972.davem@davemloft.net>
	<1184208521.6005.695.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 12 Jul 2007 12:48:41 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: rusty@rustcorp.com.au
Cc: hch@lst.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> We drop the lock after I/O, and then do this wakeup.  Meanwhile the
> other task might have exited.

I already understand what you're doing.

Is it possible to use exit notifiers to handle this case?
That's what I'm trying to suggest. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
