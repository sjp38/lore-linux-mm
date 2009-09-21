Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E1C816B0092
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 13:58:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1938282C392
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:00:20 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MaGmstsiYdyy for <linux-mm@kvack.org>;
	Mon, 21 Sep 2009 14:00:15 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 776D182C3B6
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:00:11 -0400 (EDT)
Date: Mon, 21 Sep 2009 13:54:12 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
In-Reply-To: <20090921174656.GS12726@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <20090921174656.GS12726@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Lets just keep SLQB back until the basic issues with memoryless nodes are
resolved. There does not seem to be an easy way to deal with this. Some
thought needs to go into how memoryless node handling relates to per cpu
lists and locking. List handling issues need to be addressed before SLQB.
can work reliably. The same issues can surface on x86 platforms with weird
NUMA memory setups.

Or just allow SLQB for !NUMA configurations and merge it now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
