Date: Thu, 19 Jul 2007 19:27:46 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: lguest, Re: -mm merge plans for 2.6.23
Message-ID: <20070719172746.GA17710@lst.de>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <20070711122324.GA21714@lst.de> <1184203311.6005.664.camel@localhost.localdomain> <20070711.192829.08323972.davem@davemloft.net> <1184208521.6005.695.camel@localhost.localdomain> <20070711212435.abd33524.akpm@linux-foundation.org> <1184215943.6005.745.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184215943.6005.745.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hch@lst.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 12, 2007 at 02:52:23PM +1000, Rusty Russell wrote:
> This is solely for the wakeup: you don't wake an mm 8)
> 
> The mm reference is held as well under the big lguest_mutex (mm gets
> destroyed before files get closed, so we definitely do need to hold a
> reference).
> 
> I just completed benchmarking: the cached wakeup with the current naive
> drivers makes no difference (at one stage I was playing with batched
> hypercalls, where it seemed to help).
> 
> Thanks Christoph, DaveM!

The version that just got into mainline still has the __put_task_struct
export despite not needing it anymore.  Care to fix this up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
