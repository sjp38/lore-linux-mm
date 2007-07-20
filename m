Date: Fri, 20 Jul 2007 09:15:44 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: lguest, Re: -mm merge plans for 2.6.23
Message-ID: <20070720071544.GA25717@lst.de>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <20070711122324.GA21714@lst.de> <1184203311.6005.664.camel@localhost.localdomain> <20070711.192829.08323972.davem@davemloft.net> <1184208521.6005.695.camel@localhost.localdomain> <20070711212435.abd33524.akpm@linux-foundation.org> <1184215943.6005.745.camel@localhost.localdomain> <20070719172746.GA17710@lst.de> <1184902046.10380.257.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184902046.10380.257.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 20, 2007 at 01:27:26PM +1000, Rusty Russell wrote:
> On Thu, 2007-07-19 at 19:27 +0200, Christoph Hellwig wrote:
> > The version that just got into mainline still has the __put_task_struct
> > export despite not needing it anymore.  Care to fix this up?
> 
> No, it got patched in then immediately patched out again.  Andrew
> mis-mixed my patches, but there have been so many of them I find it hard
> to blame him.

Indeed, the export is gone in last mainline gone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
