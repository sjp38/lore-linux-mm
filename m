Subject: Re: lguest, Re: -mm merge plans for 2.6.23
From: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20070719172746.GA17710@lst.de>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <20070711122324.GA21714@lst.de>
	 <1184203311.6005.664.camel@localhost.localdomain>
	 <20070711.192829.08323972.davem@davemloft.net>
	 <1184208521.6005.695.camel@localhost.localdomain>
	 <20070711212435.abd33524.akpm@linux-foundation.org>
	 <1184215943.6005.745.camel@localhost.localdomain>
	 <20070719172746.GA17710@lst.de>
Content-Type: text/plain
Date: Fri, 20 Jul 2007 13:27:26 +1000
Message-Id: <1184902046.10380.257.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-07-19 at 19:27 +0200, Christoph Hellwig wrote:
> The version that just got into mainline still has the __put_task_struct
> export despite not needing it anymore.  Care to fix this up?

No, it got patched in then immediately patched out again.  Andrew
mis-mixed my patches, but there have been so many of them I find it hard
to blame him.

Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
