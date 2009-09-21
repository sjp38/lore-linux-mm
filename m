Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 98F116B004D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:21:08 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 33FFE82C6D8
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:23:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HV-Lgfk4rnJA for <linux-mm@kvack.org>;
	Mon, 21 Sep 2009 14:23:22 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BA03A82C6DC
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 14:23:13 -0400 (EDT)
Date: Mon, 21 Sep 2009 14:17:40 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 0/3] Fix SLQB on memoryless configurations V2
In-Reply-To: <20090921180739.GT12726@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0909211412050.3106@V090114053VZO-1>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie> <20090921174656.GS12726@csn.ul.ie> <alpine.DEB.1.10.0909211349530.3106@V090114053VZO-1> <20090921180739.GT12726@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Sep 2009, Mel Gorman wrote:
> Can you spot if there is something fundamentally wrong with patch 2? I.e. what
> is wrong with treating the closest node as local instead of only the
> closest node?

Depends on the way locking is done for percpu queues (likely lockless).
A misidentification of the numa locality of an object may result in locks
not being taken that should have been taken.

> > Or just allow SLQB for !NUMA configurations and merge it now.
> >
>
> Forcing SLQB !NUMA will not rattle out any existing list issues
> unfortunately :(.

But it will make SLQB work right in permitted configurations. The NUMA
issues can then be fixed later upstream.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
