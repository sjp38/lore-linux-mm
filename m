Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AFD296B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:49:44 -0400 (EDT)
Date: Tue, 28 Sep 2010 07:49:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad forfile/email/web
 servers
In-Reply-To: <1285677740.30176.1397281937@webmail.messagingengine.com>
Message-ID: <alpine.DEB.2.00.1009280748590.4144@router.home>
References: <52C8765522A740A4A5C027E8FDFFDFE3@jem> <20100921090407.GA11439@csn.ul.ie> <20100927110049.6B31.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009270828510.7000@router.home> <1285629420.10278.1397188599@webmail.messagingengine.com>
 <alpine.DEB.2.00.1009280727370.4144@router.home> <1285677740.30176.1397281937@webmail.messagingengine.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bron Gondwana <brong@fastmail.fm>
Cc: Robert Mueller <robm@fastmail.fm>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Bron Gondwana wrote:

> Is this what's happening, or is IO actually coming from disk in preference
> to the remote node?  I can certainly see the logic behind preferring to
> reclaim the local node if that's all that's happening - though the OS should
> be allocating the different tasks more evenly across the nodes in that case.

Not sure about the disk. I did not see anything that would indicate and
issue with only being able to do 32 bit and I am no expert on the device
driver operations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
