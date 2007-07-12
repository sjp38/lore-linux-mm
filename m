Date: Wed, 11 Jul 2007 20:35:18 -0700 (PDT)
Message-Id: <20070711.203518.59469474.davem@davemloft.net>
Subject: Re: lguest, Re: -mm merge plans for 2.6.23
From: David Miller <davem@davemloft.net>
In-Reply-To: <1184210118.6005.719.camel@localhost.localdomain>
References: <1184208521.6005.695.camel@localhost.localdomain>
	<20070711.195126.02300228.davem@davemloft.net>
	<1184210118.6005.719.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 12 Jul 2007 13:15:18 +1000
Return-Path: <owner-linux-mm@kvack.org>
To: rusty@rustcorp.com.au
Cc: hch@lst.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Sure, the process has /dev/lguest open, so I can do something in the
> close routine.  Instead of keeping a reference to the tsk, I can keep a
> reference to the struct lguest (currently it doesn't have or need a
> refcnt).  Then I need another lock, to protect lg->tsk.
> 
> This seems like a lot of dancing to avoid one export.  If it's that
> important I'd far rather drop the code and do a normal wakeup under the
> big lguest lock for 2.6.23.

I'm not against the export, so use if it really helps.

Ref-counting just seems clumsy to me given how the hw assisted
virtualization stuff works on platforms I am intimately familiar with
:)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
