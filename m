Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 319796B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:14:17 -0400 (EDT)
Date: Tue, 21 Sep 2010 09:14:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web
 servers
In-Reply-To: <20100921090407.GA11439@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009210911270.1271@router.home>
References: <1284349152.15254.1394658481@webmail.messagingengine.com> <20100916184240.3BC9.A69D9226@jp.fujitsu.com> <20100920093440.GD1998@csn.ul.ie> <52C8765522A740A4A5C027E8FDFFDFE3@jem> <20100921090407.GA11439@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rob Mueller <robm@fastmail.fm>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Sep 2010, Mel Gorman wrote:

> > However there's still another question, why is this problem happening at
> > all for us? I know almost nothing about NUMA, but from other posts, it
> > sounds like the problem is the memory allocations are all happening on
> > one node?
>
> Yes.

This could be a screwy hardware issue as pointed out before. Certain
controllers restrict the memory that I/O can be done to also (32 bit
controller only able to do I/O to lower 2G?, controller on a PCI bus that
is local only to a particular node) which would make balancing
the file cache difficult.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
