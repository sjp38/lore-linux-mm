Date: Wed, 11 Jul 2007 19:28:29 -0700 (PDT)
Message-Id: <20070711.192829.08323972.davem@davemloft.net>
Subject: Re: lguest, Re: -mm merge plans for 2.6.23
From: David Miller <davem@davemloft.net>
In-Reply-To: <1184203311.6005.664.camel@localhost.localdomain>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<20070711122324.GA21714@lst.de>
	<1184203311.6005.664.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 12 Jul 2007 11:21:51 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: rusty@rustcorp.com.au
Cc: hch@lst.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> To do inter-guest (ie. inter-process) I/O you really have to make sure
> the other side doesn't go away.

You should just let it exit and when it does you receive some kind of
exit notification that resets your virtual device channel.

I think the reference counting approach is error and deadlock prone.
Be more loose and let the events reset the virtual devices when
guests go splat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
